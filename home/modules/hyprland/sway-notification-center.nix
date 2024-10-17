{ config, lib, pkgs, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      swaynotificationcenter
      libnotify
    ];

    home.file.".config/swaync/config.json".text = builtins.toJSON {
      positionX = "center";
      positionY = "top";
      fit-to-screen = false;
      control-center-height = 800;
    };

    home.file.".config/swaync/style.css".source = pkgs.fetchurl {
      url = "https://github.com/catppuccin/swaync/releases/download/v0.2.3/mocha.css";
      hash = "sha256-Hie/vDt15nGCy4XWERGy1tUIecROw17GOoasT97kIfc=";
    };

    wayland.windowManager.hyprland.settings.exec-once = [
      "swaync"
    ];
  };
}
