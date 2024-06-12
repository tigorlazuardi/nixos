{ ... }:
{
  boot.loader = {
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
