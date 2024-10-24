{ config, pkgs, lib, ... }:
{
  env.DATABASE_URL = "postgres://sander@localhost:5431/flakestry";
  env.BASE_PATH = "localhost:3000";

  packages = [
    pkgs.openssl
    pkgs.cargo-watch
    pkgs.elmPackages.elm-land
    pkgs.sqlx-cli
    pkgs.flyctl
    pkgs.openapi-generator-cli
  ]
  ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.CF
    pkgs.darwin.Security
    pkgs.darwin.configd
    pkgs.darwin.dyld
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
    initialDatabases = [
      {
        name = "flakestry";
      }
    ];
  };
  services.caddy.enable = true;
  services.caddy.virtualHosts.":8888" = {
    extraConfig = ''
      root * ${config.devenv.root}/frontend/dist

      route {
        handle_path /api/* {
          reverse_proxy localhost:3000
        }

        reverse_proxy localhost:1234
      }
    '';
  };

  enterTest = ''
    pushd backend
    cargo build
    popd
  '';

  # Generate the Elm API client
  scripts.generate-elm-api.exec = ''
    generate-openapi

    echo generating frontend/generated-api
    openapi-generator-cli generate \
      --input-spec ${config.devenv.root}/backend-rs/openapi.json \
      --enable-post-process-file \
      --generator-name elm \
      --template-dir ${config.devenv.root}/frontend/templates \
      --type-mappings object=JsonObject \
      --output ${config.devenv.root}/frontend/generated-api
  '';

  scripts.generate-openapi.exec = ''
    cd backend && cargo run --bin gen-openapi
  '';

  tasks = {
    "flakestry:migrate" = {
      exec = "sqlx migrate run";
    };
  };

  processes = {
    backend.exec = "cd backend && cargo watch -x run";
    frontend.exec = "cd frontend && elm-land server";
  };

  # containers.staging = mkContainer "staging";
  # containers.production = mkContainer "production";

  pre-commit.settings.rust.cargoManifestPath = "./backend/Cargo.toml";

  pre-commit.hooks = {
    rustfmt.enable = true;
    shellcheck.enable = true;
    nixfmt-rfc-style.enable = true;
    elm-format.enable = true;
  };
}
