use anyhow::Context;
use axum::{
    extract::{Json, State},
    http::HeaderMap,
};
use chrono::{NaiveDateTime, Utc};
use octocrab::Octocrab;
use opensearch::IndexParts;
use opensearch::OpenSearch;
use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::{postgres::PgRow, FromRow, PgPool, Row};
use std::sync::Arc;
use tracing::error;

use crate::api::flake::Release;
use crate::common::{AppError, AppState};

#[derive(Deserialize, Serialize, utoipa::ToSchema)]
pub struct Publish {
    pub owner: String,
    pub repository: String,
    pub ref_: Option<String>,
    pub version: Option<String>,
    #[schema(value_type = Option<Object>)]
    pub metadata: Option<serde_json::Value>,
    pub metadata_errors: Option<String>,
    pub readme: Option<String>,
    #[schema(value_type = Option<Object>)]
    pub outputs: Option<serde_json::Value>,
    pub outputs_errors: Option<String>,
}

#[utoipa::path(
        post,
        path = "/publish",
        request_body = Publish,
        responses(
            (status = 201, description = "Created", body = ())
        )
    )]
pub async fn post_publish(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    Json(publish): Json<Publish>,
) -> Result<(), AppError> {
    let github_token = headers
        .get("github_token")
        .ok_or_else(|| AppError::BadRequest("Missing GitHub token".into()))?
        .to_str()
        .map_err(|_| AppError::BadRequest("Invalid GitHub token".into()))?;

    error!(
        "Publishing flake {}/{}@{:?}...",
        publish.owner, publish.repository, publish.ref_
    );
    error!("github_token: {}", github_token);

    let owner_name = publish.owner.clone();
    let repository_name = publish.repository.clone();

    let ref_ = if let Some(ref ref_) = publish.ref_ {
        ref_.clone()
    } else if let Some(ref version) = publish.version {
        version.clone()
    } else {
        return Err(AppError::BadRequest(
            "Neither 'ref' nor 'version' were provided".into(),
        ));
    };

    let octocrab = Octocrab::builder()
        .personal_token(github_token)
        .build()
        .expect("Failed to create Octocrab client");

    let commit = octocrab
        .commits(&owner_name, &repository_name)
        .get(ref_)
        .await
        .expect("Failed to get commit");

    let commit_sha = commit.sha;
    let commit_date = commit
        .commit
        .committer
        .and_then(|c| c.date)
        .unwrap_or_else(|| Utc::now());

    let version = publish
        .version
        .clone()
        .unwrap_or_else(|| commit_date.format("%Y%m%d%H%M%S").to_string());

    let owner = get_or_create_owner(&state.pool, &owner_name).await?;
    let repo = get_or_create_repo(&state.pool, &repository_name, owner.id).await?;

    // if version_exists(&state.pool, &version, repo.id).await? {
    //     return Err(AppError::BadRequest(format!(
    //         "Version {} already exists",
    //         version
    //     )));
    // }

    let description = publish
        .metadata
        .as_ref()
        .and_then(|m| m.get("description").and_then(|d| d.as_str()))
        .map(String::from);
    let readme_path = publish.readme.clone().unwrap_or("README.md".into());
    let readme = get_readme(
        &octocrab,
        &owner_name,
        &repository_name,
        &commit_sha,
        &readme_path,
    )
    .await
    .unwrap_or_default();
    // let readme = Some(String::from("HELLO"));

    let release = create_release(
        &state.pool,
        repo.id,
        &version,
        &commit_sha,
        description,
        readme,
        publish,
    )
    .await?;

    index_release(&state.opensearch, &release, &owner_name, &repository_name)
        .await
        .expect("Failed to index release");

    Ok(())
}

#[derive(serde::Serialize, PartialEq, Eq, utoipa::ToSchema)]
pub struct GitHubOwner {
    #[serde(skip_serializing)]
    id: i32,
    name: String,
    created_at: NaiveDateTime,
}

impl FromRow<'_, PgRow> for GitHubOwner {
    fn from_row(row: &PgRow) -> sqlx::Result<Self> {
        Ok(Self {
            id: row.try_get("id")?,
            name: row.try_get("name")?,
            created_at: row.try_get("created_at")?,
        })
    }
}

async fn get_or_create_owner(pool: &PgPool, name: &str) -> Result<GitHubOwner, AppError> {
    let owner = sqlx::query_as(
        "INSERT INTO githubowner (name)
        VALUES ($1)
        ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
        RETURNING id, name, created_at",
    )
    .bind(name)
    .fetch_one(pool)
    .await
    .unwrap();
    // .context("Failed to fetch owner from database")?;

    Ok(owner)
}

#[derive(serde::Serialize, PartialEq, Eq, utoipa::ToSchema)]
pub struct GitHubRepo {
    #[serde(skip_serializing)]
    id: i32,
    name: String,
    description: String,
    #[serde(skip_serializing)]
    owner_id: i32,
    created_at: NaiveDateTime,
}

impl FromRow<'_, PgRow> for GitHubRepo {
    fn from_row(row: &PgRow) -> sqlx::Result<Self> {
        Ok(Self {
            id: row.try_get("id")?,
            name: row.try_get("name")?,
            description: row.try_get("description").unwrap_or_default(),
            created_at: row.try_get("created_at")?,
            owner_id: row.try_get("owner_id")?,
        })
    }
}

async fn get_or_create_repo(
    pool: &PgPool,
    name: &str,
    owner_id: i32,
) -> Result<GitHubRepo, AppError> {
    let repo = sqlx::query_as::<_, GitHubRepo>(
        "INSERT INTO githubrepo (name, owner_id)
        VALUES ($1, $2)
        ON CONFLICT (name, owner_id) DO UPDATE SET
            name = EXCLUDED.name,
            owner_id = EXCLUDED.owner_id
        RETURNING id, name, description, owner_id, created_at",
    )
    .bind(name)
    .bind(owner_id)
    .fetch_one(pool)
    .await
    .unwrap();
    // .context("Failed to create or fetch repo from database")?;

    Ok(repo)
}

async fn version_exists(pool: &PgPool, version: &str, repo_id: i32) -> Result<bool, AppError> {
    let exists = sqlx::query_scalar::<_, bool>(
        "SELECT EXISTS(SELECT 1 FROM release WHERE version = $1 AND repo_id = $2)",
    )
    .bind(version)
    .bind(repo_id)
    .fetch_one(pool)
    .await
    .context("Failed to check if version exists in database")?;

    Ok(exists)
}

async fn get_readme(
    octocrab: &Octocrab,
    owner: &str,
    repo: &str,
    ref_: &str,
    path: &str,
) -> Result<Option<String>, octocrab::Error> {
    octocrab
        .repos(owner, repo)
        .get_readme()
        // .path(path)
        .r#ref(ref_)
        .send()
        .await
        .map(|readme| readme.content)
}

async fn create_release(
    pool: &PgPool,
    repo_id: i32,
    version: &str,
    commit: &str,
    description: Option<String>,
    readme: Option<String>,
    publish: Publish,
) -> Result<Release, AppError> {
    let release = sqlx::query_as(
        "INSERT INTO release (
          repo_id,
          readme_filename,
          readme,
          version,
          commit,
          description,
          meta_data,
          meta_data_errors,
          outputs,
          outputs_errors
          )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        ON CONFLICT (repo_id, version) DO UPDATE SET
            readme_filename = EXCLUDED.readme_filename,
            readme = EXCLUDED.readme,
            description = EXCLUDED.description
        RETURNING
            release.id as id,
            repo_id,
            readme_filename,
            readme,
            version,
            commit,
            description,
            release.created_at as created_at,
            meta_data,
            meta_data_errors,
            outputs,
            outputs_errors",
    )
    .bind(repo_id)
    .bind(publish.readme)
    .bind(readme)
    .bind(version)
    .bind(commit)
    .bind(description)
    .bind(publish.metadata)
    .bind(publish.metadata_errors)
    .bind(publish.outputs)
    .bind(publish.outputs_errors)
    .fetch_one(pool)
    .await
    .unwrap();
    // .context("Failed to create or fetch release from database")?;

    Ok(release)
}

async fn index_release(
    opensearch: &OpenSearch,
    release: &Release,
    owner: &str,
    repo: &str,
) -> Result<(), opensearch::Error> {
    let document = json!({
        "description": release.description,
        "readme": release.readme,
        "outputs": release.outputs,
        "repo": repo,
        "owner": owner,
    });

    opensearch
        .index(IndexParts::IndexId("flakes", &release.id.to_string()))
        .body(document)
        .refresh(opensearch::params::Refresh::True)
        .send()
        .await?;

    Ok(())
}
