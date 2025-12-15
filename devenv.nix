{ pkgs, lib, ... }:
{
  dotenv.enable = true;

  packages = [
    pkgs.openssl
    pkgs.cargo-watch
    pkgs.elm-land
    pkgs.sqlx-cli
    pkgs.flyctl
    pkgs.openapi-generator-cli
  ];

  languages.javascript = {
    enable = true;
    npm.install.enable = true;
  };

  languages.elm.enable = true;
  languages.typescript.enable = true;

  languages.rust = {
    enable = true;
    channel = "stable";
  };

  services.opensearch.enable = true;
  services.postgres = {
    enable = true;
    listen_addresses = "localhost";
    port = 5431;
    initialDatabases = [ { name = "flakestry"; } ];
  };
  services.caddy.enable = true;
  services.caddy.config = builtins.readFile ./Caddyfile;

  enterTest = ''
    pushd backend
    cargo build
    popd
  '';

  enterShell = ''
    echo "Entering shell"
    cargo --version
    elm-land --version
  '';

  # Generate the Elm API client
  scripts.generate-elm-api.exec = ''
    generate-openapi

    echo generating frontend/generated-api
    openapi-generator-cli generate \
      --input-spec backend/openapi.json \
      --enable-post-process-file \
      --generator-name elm \
      --template-dir frontend/templates \
      --type-mappings object=JsonObject \
      --output frontend/generated-api
  '';

  scripts.generate-openapi.exec = ''
    cd backend && cargo run --bin gen-openapi
  '';

  scripts.run-migrations.exec = ''
    sqlx migrate run
  '';

  scripts.flakestry-publish.exec = "cd backend && cargo run --bin publish -- $@";

  processes = {
    backend = {
      exec = "cd backend && cargo watch -x run";
      process-compose.depends_on = {
        opensearch.condition = "process_healthy";
        postgres.condition = "process_healthy";
      };
    };
    frontend.exec = "cd frontend && elm-land server";
  };

  git-hooks = {
    hooks = {
      rustfmt.enable = true;
      # TODO: upstream
      # rustfmt.packageOverrides.rustfmt = config.languages.rust.toolchain.rustfmt;

      shellcheck.enable = true;
      nixfmt.enable = true;
      elm-format.enable = true;
    };
    settings.rust.cargoManifestPath = "./backend/Cargo.toml";
  };
}
