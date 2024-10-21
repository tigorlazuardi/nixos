{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  sops.secrets."smb/secrets" = {
    owner = config.profile.user.name;
  };

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ amdvlk ];
  };

  environment.systemPackages = with pkgs; [ lact ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];

  system.fsPackages = [
    pkgs.bindfs
    pkgs.cifs-utils
  ];
  fileSystems."/nas" = {
    device = "//192.168.100.5/nas";
    fsType = "cifs";
    options = [
      "_netdev"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "uid=${toString config.profile.user.uid}"
      "gid=${toString config.profile.user.gid}"
      "credentials=${config.sops.secrets."smb/secrets".path}"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6a987bc7-1f00-4494-bcef-b0f8afc62b7b";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/812C-A3A9";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/0add1f95-4cd5-4d44-876e-c1b381b7d133";
    fsType = "ext4";
  };

  fileSystems."/workstation" = {
    device = "/dev/disk/by-uuid/7a3a7a8a-91d5-43fb-a80b-376bacdb54ec";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/15139a5f-a695-47a1-bd59-7e530989860c"; } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp7s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
