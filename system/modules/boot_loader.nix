{ config, lib, ... }:
let
  grub = config.profile.grub;
in
lib.mkMerge [
  {
    boot.loader = lib.mkIf grub.enable {
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
      grub = {
        enable = true;
        efiSupport = true;
        useOSProber = true;
        device = "nodev"; # used nodev because of efi support
      };
    };
  }
  {
    boot.loader = lib.mkIf (!grub.enable) {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
    };
  }
]
