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

Projects out in the wild



### Initialize devenv

Lets create the initial devenv files:

```console
devenv init
```

This will create the following two files:

- `devenv.nix`: used to specify your developer environment in Nix.
- `devenv.yaml`: lets you specify dependencies, or inputs, for your project.

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

### Language support

> [!DOCS]
> https://devenv.sh/languages/

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
> You can switch to a different channel by specifying the `channel` attribute.
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



[fenix]: https://github.com/nix-community/fenix
