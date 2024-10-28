{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.hyprland;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rofi-wayland
      rbw
      rofi-rbw-wayland
      ydotool
      pinentry-tty
    ];

    sops = {
      secrets."bitwarden/config.json" = {
        sopsFile = ../../../secrets/bitwarden.yaml;
        path = "${config.home.homeDirectory}/.config/rbw/config.json";
      };
    };

    wayland.windowManager.hyprland.settings.bind = [
      # Needs to login first to bitwarden via `rbw login` command
      "$mod, Z, exec, rofi-rbw"
    ];
  };
}
