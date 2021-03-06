{ config, pkgs, lib, ... }:

with lib;
let
  channels = [
    pkgs
    pkgs.nixos-unstable
    pkgs.nixpkgs-unstable
    pkgs.nixos-unstable-small
  ];

  getNewestFromChannels = name: pkgs.versions.latestVersion ((_: map (channel: (getAttr name channel.jetbrains)) channels) name);

  jetPkgs = [
    (getNewestFromChannels "idea-ultimate")
    (getNewestFromChannels "clion")
    (getNewestFromChannels "datagrip")
    (getNewestFromChannels "jdk")
    (getNewestFromChannels "pycharm-professional")
    (getNewestFromChannels "webstorm")
  ];

in
  {
    imports = [
      ./channels.nix
    ];

    home-manager.users.evanjs = {
      home.packages = [ ]
      ++ jetPkgs
      ;
    };
  }
