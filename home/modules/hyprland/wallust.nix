{ pkgs, unstable, lib, config, ... }:
let
  cfg = config.profile.hyprland;
  wallust = cfg.wallust;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.imagemagick
      # unstable.wallust
      (pkgs.callPackage ./wallust-build.nix { })
    ];

    home. file.".config/wallust/templates" = {
      source = ./wallust-templates;
      recursive = true;
    };

    home.file.".config/wallust/wallust.toml".source =
      let
        tomlFormat = pkgs.formats.toml { };
      in
      tomlFormat.generate
        "wallust.toml"
        {
          # See https://codeberg.org/explosion-mental/wallust/src/branch/master/wallust.toml
          # for more information about the configuration options.

          # How the image is parse, in order to get the colors:
          # full - resized - wal - thumb -  fastresize - kmeans
          backend = wallust.backend;

          # What color space to use to produce and select the most prominent colors:
          # lab - labmixed - lch - lchmixed
          color_space = wallust.colorSpace;
          threshold = wallust.threshold;

          # Use the most prominent colors in a way that makes sense, a scheme color palette:
          # dark - dark16 - darkcomp - darkcomp16
          # light - light16 - lightcomp - lightcomp16
          # harddark - harddark16 - harddarkcomp - harddarkcomp16
          # softdark - softdark16 - softdarkcomp - softdarkcomp16
          # softlight - softlight16 - softlightcomp - softlightcomp16
          palette = wallust.palette;

          # Ensures a "readable contrast" (OPTIONAL, disabled by default)
          # Should only be enabled when you notice an unreadable contrast frequently happening
          # with your images. The reference color for the contrast is the background color.
          check_contrast = wallust.checkContrast;

          # Color saturation, between [1% and 100%] (OPTIONAL, disabled by default)
          # usually something higher than 50 increases the saturation and below
          # decreases it (on a scheme with strong and vivid colors)
          # saturation = 50;

          # Alpha value for templating, by default 100 (no other use whatsoever)
          alpha = wallust.alpha;

          templates =
            # Templates requires certain syntax
            #
            # See: https://codeberg.org/explosion-mental/wallust/wiki/wallust.1-Man-Page
            # Note that the documentation is for 3.x and above.
            let
              out = config.home.homeDirectory + "/.cache/wallust";
            in
            {
              waybar = {
                template = "waybar.css";
                # target = out + "/waybar.css";
                target = "${config.home.homeDirectory}/.config/waybar/style.css";
              };
              wlogout = {
                template = "wlogout.css";
                target = out + "/wlogout.css";
              };
              hyprland = {
                template = "hyprland.conf";
                target = out + "/hyprland.conf";
              };
              kitty = {
                template = "kitty.conf";
                target = "${config.home.homeDirectory}/.config/kitty/kitty.d/99-colors.conf";
              };
              base16-nvim = {
                template = "base16-nvim.lua";
                target = out + "/base16-nvim.lua";
              };
              rofi = {
                template = "rofi.rasi";
                target = out + "/rofi.rasi";
              };
              alacritty = {
                template = "alacritty.toml";
                target = out + "/alacritty.toml";
              };
              foot = {
                template = "foot.ini";
                target = "${config.home.homeDirectory}/.config/foot/colors.ini";
              };
            };
        };
  };

}
