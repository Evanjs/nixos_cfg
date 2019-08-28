{ lib, pkgs, config, ... }:
with lib;

let
  cfg = config.mine.dev.rust;

  # TODO: Is there a clean way to provide options for "packs" of plugins? e.g. debug = [ "llvm-tools-preview" "lldb-preview" ];
  /* Some more examples:
    ```
    base-extensions = [
      "rust-std"
      "rust-src"
    ];

    debug = [
      "llvm-tools-preview"
    ];

    std-only = [
      "rust-std"
    ];

    utilities = [
      "clippy-preview"
      "rustfmt-preview"
      "rust-analysis"
    ];
    ```
  */
  rust-extensions = [
    "clippy-preview"
    "miri-preview"
    "rls-preview"
    "rustfmt-preview"
    "llvm-tools-preview"
    "lldb-preview"
    "rust-analysis"
    "rust-std"
    "rust-src"
  ];
in
  {
    options.mine.dev.rust = {
      enable = mkEnableOption "Rust development environment";
      /* TODO: Given a set of plugins, can we try to download them and fail gracefully if some don't exist?
        There are multiple ways this could be achieved.  We could provide options to:
        - Determine the importance of plugins being downloaded
        - Provide an option, e.g. requiredPlugins option, which tries to find the newest version on the configured channel if a plugin is not available on the newest release
        - Provide an option that determines the maxmium versions we should check if any requiredPlugins are not found in the latest configured channel
        - Another option, e.g. desiredPlugins, could define the plugins that are desired, but can be ignored if they are not available on the latest release of the configured channel
        - Given requiredPlugins and desiredPlugins are defined, we will attempt to download the latest version of the toolchain.
          We will attempt to downlaod any desired plugins, and ignore them if they cannot be downloaded.
          We will attempt to download the required plugins, and if they cannot be found, go backwards and check if any previous versions contain the entire list
          Stop checking previous versions for required plugins once a (potentially configured) maximum is reached
      */
      plugins = mkOption {
        default = [ "rust-std" ];
        type = types.nullOr (types.listOf (types.enum rust-extensions));
        example = ''
          # Also download rust-src for proper racer/rls/IntelliJ Rust integration, etc.
          [ "rust-std" "rust-src" ];
        '';
      };

      channel = mkOption {
        default = "stable";
        type = types.nullOr (types.enum [ "nightly" "beta" "stable" ]);
        description = "The release channel to use.";
      };

      package = mkOption {
        default = (getAttr cfg.channel pkgs.latest.rustChannels).rust.override { extensions = cfg.plugins; };
        example = ''
          pkgs.latest.rustChannels.nightly.rust.override { extensions = [ "rust-std" "clippy-preview" ]; }
        '';
        type = types.nullOr types.package;
        description = "The rust package to use.  Cannot be used when defining the channel or plugins.";
      };

      extraPackages = mkOption {
        default = [ pkgs.cargo-edit pkgs.cargo-update ];
        example = [ pkgs.cargo-edit pkgs.cargo-license pkgs.cargo-generate ];
        type = types.nullOr (types.listOf types.package);
        description = "Packages to install in addition to the Rust toolchain and any configured plugins";
      };
    };

    config = mkIf cfg.enable {
      nixpkgs.overlays = [
        (import "${(import ../../sources).nixpkgs-mozilla}/rust-overlay.nix")
      ];

      mine.userConfig = {
        home.packages = [ cfg.package ] ++ cfg.extraPackages;
      };
    };
  }