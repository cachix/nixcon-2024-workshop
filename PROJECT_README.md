# [flakestry.dev](https://flakestry.dev)

A public registry of Nix flakes aiming to supersede [search.nixos.org](https://search.nixos.org/flakes).

Built using [elm.land](https://elm.land/) and [Axum](https://github.com/tokio-rs/axum).

Maintainers:
  - [@domenkozar](https://github.com/domenkozar)
  - [@sandydoo](https://github.com/sandydoo)

## Development

### Prerequisites

You will need the following tools to build and run the project:

- [Rust](https://www.rust-lang.org/tools/install)
- [NPM](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)
- [TypeScript](https://www.typescriptlang.org/download)
- [Elm](https://guide.elm-lang.org/install/elm.html)
- [Elm Land](https://elm.land/guide/)
- [Postgres](https://www.postgresql.org/download/)
- [OpenSearch](https://opensearch.org/docs/latest/getting-started/install/)
- [Caddy](https://caddyserver.com/docs/install)
- [Docker](https://docs.docker.com/get-docker/)
- [OpenAPI Generator](https://github.com/OpenAPITools/openapi-generator)

### Setup

#### JavaScript

Install JavaScript dependencies:

```console
npm install
```

#### Postgres

Launch a postgres instance and create the database:

```console
docker run --name flakestry-postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres
```

Create the database and run the migrations:

```console
DATABASE_URL=postgres://localhost:5432/flakestry sqlx database setup
```

#### OpenSearch

Launch an OpenSearch instance:

```console
docker run -p 9200:9200 -p 9600:9600 -e "discovery.type=single-node" opensearchproject/opensearch:latest
```

### Caddy

Launch the Caddy server:

```console
caddy run
```

#### Run the backend

```console
cd backend && cargo run
```

#### Run the frontend

```console
cd frontend && elm-land server
```
