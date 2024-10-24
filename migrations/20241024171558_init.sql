CREATE TABLE githubowner (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE githubrepo (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    owner_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES githubowner (id),
    CONSTRAINT unique_owner_name UNIQUE (owner_id, name)
);

CREATE TABLE release (
    id SERIAL PRIMARY KEY,
    repo_id INTEGER NOT NULL,
    readme_filename TEXT,
    readme TEXT,
    version TEXT NOT NULL,
    commit TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    meta_data JSONB DEFAULT '{}',
    meta_data_errors TEXT,
    outputs JSONB DEFAULT '{}',
    outputs_errors TEXT,
    FOREIGN KEY (repo_id) REFERENCES githubrepo (id),
    CONSTRAINT unique_repo_version UNIQUE (repo_id, version)
);

CREATE INDEX idx_githubrepo_owner_id ON githubrepo (owner_id);
CREATE INDEX idx_release_repo_id ON release (repo_id);
