use backend_rs::api::Publish;
use clap::Parser;
use reqwest::Client;

#[derive(Parser, Debug)]
struct Cli {
    #[arg(short, long)]
    owner: String,

    #[arg(short, long)]
    repo: String,

    #[arg(long, name = "ref")]
    ref_: Option<String>,

    #[arg(short, long)]
    version: Option<String>,
}

#[tokio::main]
async fn main() {
    let token = std::env::var("GITHUB_TOKEN").expect("Provide a GITHUB_TOKEN");
    let args = Cli::parse();

    let client = Client::builder()
        .danger_accept_invalid_certs(true)
        .build()
        .unwrap();

    let publish = Publish {
        owner: args.owner,
        repository: args.repo,
        ref_: args.ref_,
        version: args.version,
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
