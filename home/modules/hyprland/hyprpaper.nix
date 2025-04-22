{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf false {
    home.packages = [ pkgs.hyprpaper ];

    home.file.".config/hypr/hyprpaper.conf".text =
      let
        recent_wallpaper = "${config.home.homeDirectory}/.cache/wallpaper/current";
      in
      # hyprlang
      ''
        preload = ${recent_wallpaper}
        wallpaper = ,${recent_wallpaper}
        spash = false
        ipc = on
      '';
  };
}
