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
    };

    wayland.windowManager.hyprland.settings.exec-once = [
      "swaync"
    ];
  };
}
