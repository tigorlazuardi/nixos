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

    wayland.windowManager.hyprland.settings.exec-once = [
      "swaync"
    ];
  };
}
