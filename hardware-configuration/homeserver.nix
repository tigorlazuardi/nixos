# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];
  config = {
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/439a1beb-1443-495b-9891-012605819803";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      {
        device = "/dev/disk/by-uuid/47A1-0296";
        fsType = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
      };

    fileSystems."/nas" = {
      device = "/dev/disk/by-label/WD_RED_4T_1";
      fsType = "ext4";
    };
    fileSystems."/nas/public/Music" = {
      device = "/nas/Syncthing/Sync/Music";
      fsType = "auto";
      options = [
        "defaults"
        "nofail"
        "nobootwait"
        "bind"
      ];
    };
    fileSystems."/nas/public/Public" = {
      device = "/nas/Syncthing/Sync/Public";
      fsType = "auto";
      options = [
        "defaults"
        "nofail"
        "nobootwait"
        "bind"
      ];
    };
    fileSystems = {
      "/nas/telemetry/grafana" = lib.mkIf config.profile.services.telemetry.grafana.enable {
        device = "/var/lib/grafana";
        fsType = "auto";
        options = [
          "defaults"
          "nofail"
          "nobootwait"
          "bind"
        ];
      };

      "/nas/telemetry/loki" = lib.mkIf config.profile.services.telemetry.loki.enable {
        device = "/var/lib/loki";
        fsType = "auto";
        options = [
          "defaults"
          "nofail"
          "nobootwait"
          "bind"
        ];
      };

      "/nas/telemetry/tempo" = lib.mkIf config.profile.services.telemetry.tempo.enable {
        device = "/var/lib/tempo";
        fsType = "auto";
        options = [
          "defaults"
          "nofail"
          "nobootwait"
          "bind"
        ];
      };
    };

    swapDevices = [ ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    networking.defaultGateway = "192.168.100.1";
    networking.interfaces.enp9s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.100.3";
          prefixLength = 24;
        }
        {
          address = "192.168.100.4";
          prefixLength = 24;
        }
        {
          address = "192.168.100.5";
          prefixLength = 24;
        }
      ];
    };

    services.caddy.virtualHosts."public.tigor.web.id".extraConfig = /*caddy*/ ''
      file_server browse
      root * /nas/public
    '';

    systemd.tmpfiles.settings = {
      "100-nas-public-dir" = {
        "/nas/public" = {
          d = {
            group = config.profile.user.name;
            mode = "0777";
            user = config.profile.user.name;
          };
        };
      };
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.enableAllFirmware = true;
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
      ];
    };
    environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver
  };
}
