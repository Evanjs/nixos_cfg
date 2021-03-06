{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.mine.virtualization.virtualbox;
in
{
  options.mine.virtualization.virtualbox = {
    enable = mkEnableOption "VirtualBox support";
  };

  config = mkIf cfg.enable {
    virtualisation = {
      virtualbox = {
        host = {
          enable = true;
          enableExtensionPack = true;
        };
      };
      kvmgt.enable = true;
    };
    users.extraUsers.evanjs.extraGroups = [ "vboxusers" ];
  };
}
