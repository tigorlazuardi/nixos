{
  lib,
  pkgs,
  unstable,
  config,
  ...
}:
let
  cfg = config.profile.hyprland;
  inherit (lib.meta) getExe;
  wallpaperDir = "${config.home.homeDirectory}/.cache/wallpaper";
  draw-wallpaper =
    pkgs.writeShellScriptBin "draw-wallpaper.sh" # sh
      ''
        image_file=$1
        target="${wallpaperDir}/current"
        blur_target="${wallpaperDir}/blurred.png"
        square_target="${wallpaperDir}/square.png"

        mkdir -p "${wallpaperDir}"
        echo "$image_file" > "${wallpaperDir}/origin.txt"
        cp "$image_file" "$target"
        swww img "$target"
        ${unstable.wallust}/bin/wallust run "$target"
        ${pkgs.graphicsmagick}/bin/gm convert -resize 75% -blur 50x30 "$target" "$blur_target"
        ${pkgs.imagemagick}/bin/magick "$target" -resize 25% -gravity Center -extent 1:1 "$square_target"

        if [ `pidof swaync` ]; then
            swaync-client --reload-css
        fi
      '';
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      unstable.pyprland
      pkgs.swww
    ];
    home.file.".config/hypr/pyprland.toml".source =
      let
        tomlFormat = pkgs.formats.toml { };
      in
      tomlFormat.generate "pyprland.toml" {
        pyprland.plugins = [ "wallpapers" ];
        wallpapers = {
          path = cfg.pyprland.wallpaper-dirs;
          unique = false;
          command = ''${getExe draw-wallpaper} [file]'';
        };
      };

    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "pypr"
        "swww-daemon"
        "sleep 0.2 && swww img ${config.home.homeDirectory}/.cache/wallpaper/current"
      ];
      bind = [ "$mod, W, exec, pypr wall next" ];
    };
  };
}
