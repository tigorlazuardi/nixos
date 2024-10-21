{ pkgs
, unstable
, lib
, config
, ...
}:
let
  cfg = config.profile.hyprland;
  inherit (lib.meta) getExe;
  wallpaperDir = "${config.home.homeDirectory}/.cache/wallpaper";
  initWallPaperScript =
    pkgs.writeShellScriptBin "init-wallpaper.sh"
      # sh
      ''
        init_wallpaper="${./wallpaper.jpeg}"
        cache_file="${wallpaperDir}/current"
        blurred="${wallpaperDir}/blurred.png"
        square="${wallpaperDir}/square.png"

        mkdir -p "${wallpaperDir}"

        if [ ! -f "$cache_file" ]; then
            cp "$init_wallpaper" "$cache_file"
        fi

        if [ ! -f "$blurred" ]; then
            ${pkgs.graphicsmagick}/bin/gm convert -resize 75% -blur 50x30 "$cache_file" "$blurred"
        fi

        if [ ! -f "$square" ]; then
            ${pkgs.imagemagick}/bin/magick "$cache_file" -resize 25% -gravity Center -extent 1:1 "$square"
        fi

        if [ ! -f "${config.home.homeDirectory}/.cache/wallust/sequences" ]; then
            wallust run "$cache_file"
        fi
      '';
in
{
  imports = [
    ./alacritty.nix
    ./foot.nix
    ./hyprland.nix
    ./kitty.nix
    ./rofi.nix
    ./waybar.nix
    ./wlogout.nix
  ];
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.imagemagick
      unstable.wallust
    ];

    wayland.windowManager.hyprland.settings.exec-once = lib.mkOrder 10 ([
      (getExe initWallPaperScript)
    ]);


    # See https://codeberg.org/explosion-mental/wallust/src/branch/master/wallust.toml
    home.file.".config/wallust/wallust.toml".source = (
      (pkgs.formats.toml { }).generate "wallust.toml"
        {
          backend = "kmeans";
          color_space = "lch";
          alpha = 100;
          threshold = 1;
          palette = "dark";
          checkContrast = true;
        } // cfg.wallust.settings
    );
  };
}
