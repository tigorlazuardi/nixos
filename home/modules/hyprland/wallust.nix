{
  pkgs,
  unstable,
  lib,
  config,
  ...
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
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.imagemagick
      unstable.wallust
    ];

    wayland.windowManager.hyprland.settings.exec-once = lib.mkOrder 10 [
      (getExe initWallPaperScript)
    ];

    # See https://codeberg.org/explosion-mental/wallust/src/branch/master/wallust.toml
    home.file.".config/wallust/wallust.toml".source = (
      (pkgs.formats.toml { }).generate "wallust.toml" (
        lib.attrsets.mergeAttrsList [
          {
            backend = "kmeans";
            color_space = "lch";
            alpha = 100;
            threshold = 1;
            palette = "dark";
            check_contrast = true;
          }
          cfg.wallust.settings
        ]
      )
    );

    home.file.".config/wallust/templates/hyprland.conf".text =
      # hyprlang
      ''
        $background = rgb({{background | strip}})
        $foreground = rgb({{foreground | strip}})
        $color0 = rgb({{color0 | strip}})
        $color1 = rgb({{color1 | strip}})
        $color2 = rgb({{color2 | strip}})
        $color3 = rgb({{color3 | strip}})
        $color4 = rgb({{color4 | strip}})
        $color5 = rgb({{color5 | strip}})
        $color6 = rgb({{color6 | strip}})
        $color7 = rgb({{color7 | strip}})
        $color8 = rgb({{color8 | strip}})
        $color9 = rgb({{color9 | strip}})
        $color10 = rgb({{color10 | strip}})
        $color11 = rgb({{color11 | strip}})
        $color12 = rgb({{color12 | strip}})
        $color13 = rgb({{color13 | strip}})
        $color14 = rgb({{color14 | strip}})
        $color15 = rgb({{color15 | strip}})

        general {
            col.inactive_border = $color11
        }

        decoration {
            inactive_opacity = {{alpha / 100}}
        }
      '';

    profile.hyprland.wallust.settings.templates.hyprland =
      let
        out = config.home.homeDirectory + "/.cache/wallust";
      in
      {
        template = "hyprland.conf";
        target = out + "/hyprland.conf";
      };
  };
}
