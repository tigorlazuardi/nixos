{ lib, ... }:
{
  imports = [
    ./programs.nix
    ./hyprland.nix
    ./podman.nix
    ./services.nix
    ./games.nix
    ./environments.nix
    ./flatpak.nix
  ];
  options.profile = {

    #### Required Options ####

    hostname = lib.mkOption { type = lib.types.str; };
    networking.disableWaitOnline = lib.mkEnableOption "disable waiting for network";
    networking.externalInterface = lib.mkOption {
      type = lib.types.str;
      default = "eth0";
    };

    neovim.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    user = {
      name = lib.mkOption { type = lib.types.str; };
      fullName = lib.mkOption { type = lib.types.str; };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 1000;
      };
      gid = lib.mkOption {
        type = lib.types.int;
        default = 100;
      };

      getty.autoLogin = lib.mkEnableOption "auto-login to getty";
    };

    system.stateVersion = lib.mkOption { type = lib.types.str; };

    #### Optionals ####

    grub.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    audio.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    android.enable = lib.mkEnableOption "android";
    avahi.enable = lib.mkEnableOption "avahi";
    bluetooth.enable = lib.mkEnableOption "bluetooth";
    gnome.enable = lib.mkEnableOption "gnome";
    kde.enable = lib.mkEnableOption "kde";
    networking.firewall = {
      enable = lib.mkEnableOption "firewall";
      allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [ ];
      };
    };
    printing.enable = lib.mkEnableOption "printing";
    scanner.enable = lib.mkEnableOption "scanner";
    steam.enable = lib.mkEnableOption "steam";
    sway.enable = lib.mkEnableOption "sway";
    tofi.enable = lib.mkEnableOption "tofi";
    vial.enable = lib.mkEnableOption "vial";
    security.sudo = {
      wheelNeedsPassword = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };

    security.sudo-rs = {
      enable = lib.mkEnableOption "sudo-rs";
      wheelNeedsPassword = lib.mkEnableOption "wheel password";
    };

    xkb = {
      options = lib.mkOption {
        type = lib.types.str;
        default = "caps:ctrl_modifier,shift:both_capslock_cancel";
      };
      layout = lib.mkOption {
        type = lib.types.str;
        default = "us";
      };
    };

    keyboard.language.japanese = lib.mkEnableOption "Japanese keyboard input";
    brightnessctl.enable = lib.mkEnableOption "brightnessctl";
    openssh.enable = lib.mkEnableOption "openssh";
  };
}
