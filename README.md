# NixCon 2024

## Devenv workshop

During the workshop, we'll try to create a development environment for a real-world Rust project with devenv.

https://devenv.sh/

### Prerequisites

Here's what you'll need for this workshop:

- git
- nix
- devenv
- direnv (optional)

If you haven't yet installed Nix or devenv, follow the instructions for your platform on https://devenv.sh/getting-started/.

### Clone the repo

```console
git clone https://github.com/cachix/nixcon-2024-workshop && cd nixcon-2024-workshop
```

### Explore the README

Projects out in the wild will often list their dependencies, setup steps, and other useful information in the `README.md`.
This repo has a [`PROJECT_README.md`][project-readme] that lists these requirements.

### Initialize devenv

Lets create the initial devenv files:

```console
devenv init
```

This will create the following two files:

- `devenv.nix`: used to specify your developer environment in Nix.
- `devenv.yaml`: lets you specify dependencies on other source repositories, flakes, etc, much in the style in flake inputs.

If you have `direnv` installed, the shell will automatically start loading after this command.
You can also manually load the environment with:

```console
devenv shell
```
```console
Running tasks     devenv:enterShell
Succeeded         devenv:enterShell 10ms
1 Succeeded                         10.47ms

hello from devenv
git version 2.44.0
```

Lets remove the default configuration and start from scratch.

```diff
{ pkgs, lib, config, inputs, ... }:

{
-  # https://devenv.sh/basics/
-  env.GREET = "devenv";
-
-  # https://devenv.sh/packages/
-  packages = [ pkgs.git ];
-
-  # https://devenv.sh/languages/
-  # languages.rust.enable = true;
-
-  # https://devenv.sh/processes/
-  # processes.cargo-watch.exec = "cargo-watch";
-
-  # https://devenv.sh/services/
-  # services.postgres.enable = true;
-
-  # https://devenv.sh/scripts/
-  scripts.hello.exec = ''
-    echo hello from $GREET
-  '';
-
-  enterShell = ''
-    hello
-    git --version
-  '';
-
-  # https://devenv.sh/tasks/
-  # tasks = {
-  #   "myproj:setup".exec = "mytool build";
-  #   "devenv:enterShell".after = [ "myproj:setup" ];
-  # };
-
-  # https://devenv.sh/tests/
-  enterTest = ''
-    echo "Running tests"
-    git --version | grep --color=auto "${pkgs.git.version}"
-  '';
-
-  # https://devenv.sh/pre-commit-hooks/
-  # pre-commit.hooks.shellcheck.enable = true;
-
-  # See full reference at https://devenv.sh/reference/options/
}
```

### Dotenv support

You may have noticed a notification that `devenv` has detected a `.env` file in the project.
This file contains environment variables that are used to configure the project.

We can load them into our environment with the `dotenv` integration:

```diff
{ pkgs, lib, config, inputs, ... }:

{
+  dotenv.enable = true;
}
```

```console
$ echo $DATABASE_URL
postgres://localhost:5431/flakestry

```

### Language support

> [!NOTE]
> docs: https://devenv.sh/languages/

We know from the README that we'll need `rust` for the backend, and `javascript`/`typescript` and `elm` for the frontend.
Lets enable these languages in the `devenv.nix` file.

```diff
{ pkgs, lib, config, inputs, ... }:

{
+ languages.rust.enable = true;
+
+ languages.javascript = {
+   enable = true;
+   npm.install.enable = true;
+ };
+
+ languages.typescript.enable = true;
+
+ languages.elm.enable = true;
}
```

> [!TIP]
> Some languages support more extensive versioning support than what is available in nixpkgs.
>
> For example, the Rust integration supports using a specific channel or an entirely custom toolchain.
>
> ```diff
> - languages.rust.enable = true;
> + languages.rust = {
> +   enable = true;
> +   channel = "stable";
> + };
> ```
>
> This feature uses [nix-community/fenix][fenix] under the hood.
> devenv will prompt you do add it as an input to your `devenv.yaml`.
> You can do so throught the command-line:
>
> ```console
> devenv inputs add fenix github:nix-community/fenix --follows nixpkgs
> ```

### Services

> [!NOTE]
> docs: https://devenv.sh/services/

This project relies on 3 main services:

- PostgreSQL as the main database.
- OpenSearch for indexing and searching for releases.
- Caddy as a reverse proxy for the frontend and backend.

Lets enable these services in the `devenv.nix` file.

```diff
languages.typescript.enable = true;

languages.elm.enable = true;
+
+ services.caddy.enable = true;
+ services.caddy.config = builtins.readFile ./Caddyfile;
+
+ services.opensearch.enable = true;
+
+ services.postgres = {
+   enable = true;
+   listen_addresses = "localhost";
+   port = 5432;
+   initialDatabases = [ { name = "flakestry"; } ];
+ };
```

Luanch the services with:

```console
devenv up
```

`devenv` will configure and launch the processes in an interactive `process manager`.
By default, this is [process-compose][process-compose], but we support several other implementations via `process.manager.implementation`.

To bring down the processes, use `Ctrl+C + ENTER` or run `devenv processes down` in another terminal (in the same directory).

### Scripts

You can also define custom bash scripts in `devenv.nix`.

```diff
+ scripts.run-migrations.exec = "sqlx migrate run";
```

Scripts are available in the `devenv` shell by name.
With postgres running, we can now run the migrations:

```console
run-migrations
```

### Custom processes

> [!NOTE]
> docs: https://devenv.sh/processes/

Now that we've set up our services, we can start adding custom processes for our backend and frontend.
We'll also add a few extra packages to our shell.

```diff
services.postgres = {
  enable = true;
  listen_addresses = "localhost";
  port = 5432;
  initialDatabases = [ { name = "flakestry"; } ];
};
+
+ packages = [
+   pkgs.openssl
+   pkgs.sqlx-cli
+   pkgs.cargo-watch
+   pkgs.elmPackages.elm-land
+ ];
+
+ processes.backend.exec = "cd backend && cargo watch -x run";
+ processes.frontend.exec = "cd frontend && elm-land server"
```

The backend process might fail to initialize properly if the opensearch cluster is not ready at the time of launch.

We can leverage the `depends_on` feature of `process-compose` to record this runtime ordering.
This will ensure that the backend process only starts after the `opensearch` and `postgres` services are healthy.

```diff
- processes.backend.exec = "cd backend && cargo watch -x run";
+ processes.backend = {
+   exec = "cd backend && cargo watch -x run";
+   process-compose.depends_on = {
+     opensearch.condition = "process_healthy";
+     postgres.condition = "process_healthy";
+   };
+ };
+
```

[fenix]: https://github.com/nix-community/fenix
[process-compose]: https://devenv.sh/supported-process-managers/process-compose/
[project-readme]: ./PROJECT_README.md
