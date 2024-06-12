{ lib, unstable, config, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      unstable.hyprpaper
    ];

    home.file.".config/hypr/hyprpaper.conf".text =
      let
        recent_wallpaper = "${config.home.homeDirectory}/.cache/wallpaper/current";
      in
      ''
        preload = ${recent_wallpaper}
        wallpaper = ,${recent_wallpaper}
        spash = false
        ipc = on
      '';
  };
}
