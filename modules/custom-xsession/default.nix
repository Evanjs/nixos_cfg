{ config, pkgs, lib, ... }:
with lib;
let
  notification-daemon = pkgs.notify-osd-customizable;
in
{
  imports = [
    ./autolock.nix
    ./flashback-xmonad.nix
    ../virtualgl.nix
  ];

  mine.compton.enable = true;

  environment.systemPackages = with pkgs; [
    notification-daemon
    xdg-user-dirs
  ];

  sound.mediaKeys.enable = true;

  services.autorandr = {
    enable = true;
  };

  services.xserver = {
    desktopManager.xterm.enable = false;
    displayManager = {
      gdm = {
        debug = true;
        enable = true;
        xmonad-support.enable = false;
      };
      lightdm.enable = false;
    };
    exportConfiguration = true;
    windowManager = {
      default = "xmonad";
      xmonad.enable = true;
    };
  };

  #services.compton = {
    #vSync = true;
  #};
}
