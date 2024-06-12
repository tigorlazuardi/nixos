{ config, lib, pkgs, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.rofi-wayland
    ];

    home.file.".config/rofi" = {
      source = ./rofi;
      recursive = true;
    };
  };
}
