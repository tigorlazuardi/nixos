{ lib, ... }:
{
  imports = [
    ./programs.nix
    ./hyprland.nix
  ];
  options.profile = {
    hostname = lib.mkOption {
      type = lib.types.str;
    };

    android.enable = lib.mkEnableOption "android";
    avahi.enable = lib.mkEnableOption "avahi";
    bluetooth.enable = lib.mkEnableOption "bluetooth";
    docker.enable = lib.mkEnableOption "docker";
    flatpak.enable = lib.mkEnableOption "flatpak";
    gnome.enable = lib.mkEnableOption "gnome";
    kde.enable = lib.mkEnableOption "kde";
    networking.firewall.enable = lib.mkEnableOption "firewall";
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

    firefox.enable = lib.mkEnableOption "firefox";

    brightnessctl.enable = lib.mkEnableOption "brightnessctl";
  };
}
