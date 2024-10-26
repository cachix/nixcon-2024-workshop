use backend_rs::api::Publish;
use reqwest::Client;

#[tokio::main]
async fn main() {
    let token = std::env::var("GITHUB_TOKEN").expect("Provide a GITHUB_TOKEN");

    let client = Client::builder()
        .danger_accept_invalid_certs(true)
        .build()
        .unwrap();

    let publish = Publish {
        owner: "nixos".to_string(),
        repository: "nixpkgs".to_string(),
        ref_: Some("18d2b0153d00e9735b1c535db60a39681d83ed2e".to_string()),
        version: None,
        metadata: Some(serde_json::json!({})),
        metadata_errors: None,
        readme: None,
        outputs: Some(serde_json::json!({})),
        outputs_errors: None,
    };

    let response = client
        .post("http://localhost:8888/api/publish")
        .header("github_token", token)
        .json(&publish)
        .send()
        .await
        .unwrap();

    if response.status().is_success() {
        eprintln!("Published!");
    } else {
        eprintln!("Failed!");
        eprintln!("{:?}", response.text().await.unwrap());
    }
}
