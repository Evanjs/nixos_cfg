{ config, pkgs, ... }:

let
  nodePkgs = with pkgs.nodePackages; [
    grunt-cli
    node2nix
    (pkgs.nodePackages."@angular/cli".override {
      prePatch = ''
        export NG_CLI_ANALYTICS=false
      '';
    })
  ];
in
  {
    imports = [
      ./documentation
      ./languages
      ./perf
    ];

    environment.systemPackages = with pkgs; [
      # js
      nodejs-10_x
      sass

      exercism

      # debugging
      gdb
      cgdb
      lldb

      binutils

      cmake
      gnumake

      postman

      maven3

      # testing
      websocat

      pypi2nix

      gnome3.glade
    ]
    ++ nodePkgs;
  }
