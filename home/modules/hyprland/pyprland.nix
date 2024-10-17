{ lib, pkgs, unstable, config, ... }:
let
  cfg = config.profile.hyprland;
  inherit (lib.meta) getExe;
  wallpaperDir = "${config.home.homeDirectory}/.cache/wallpaper";
  draw-wallpaper = pkgs.writeShellScriptBin "draw-wallpaper.sh" /*sh*/ ''
    image_file=$1
    target="${wallpaperDir}/current"
    blur_target="${wallpaperDir}/blurred.png"

    mkdir -p "${wallpaperDir}"
    echo "$image_file" > "${wallpaperDir}/origin.txt"
    cp "$image_file" "$target"
    swww img "$target"
    ${unstable.wallust}/bin/wallust run "$target"
    ${pkgs.imagemagick}/bin/gm convert -resize 75% -blur 50x30 "$target" "$blur_target"
  '';
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      unstable.pyprland
      unstable.swww
    ];
    home.file.".config/hypr/pyprland.toml".source =
      let
        tomlFormat = pkgs.formats.toml { };
      in
      tomlFormat.generate "pyprland.toml" {
        pyprland.plugins = [
          "wallpapers"
        ];
        wallpapers = {
          path = cfg.pyprland.wallpaper-dirs;
          unique = false;
          command = ''${getExe draw-wallpaper} [file]'';
        };
      };

    wayland.windowManager.hyprland.settings = {
      exec-once = [ "pypr" ];
      bind = [
        "$mod, W, exec, pypr wall next"
      ];
    };
  };
}
