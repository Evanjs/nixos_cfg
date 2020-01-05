{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./custom-hardware.nix

    ../../../config
    
    ../../../modules/development.nix

    ../../../modules/android.nix
    ../../../modules/db/postgresql.nix
    ../../../modules/samba/client/work.nix
    ../../../modules/virtualization/virtualbox.nix
  ];
  mine.hardware = {
    battery = false;
    cpuCount = 12;
    swap = false;
    touchpad = false;
    wlan = false;
    audio = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EB1D-0401";
    fsType = "vfat";
  };

  mine.enableUser = true;
  mine.profiles.desktop.enable = true;
  mine.rocm.enable = true;

  networking.hostName = "sekka";

  boot.initrd.checkJournalingFS = false;

  system.stateVersion = "19.09";
}
