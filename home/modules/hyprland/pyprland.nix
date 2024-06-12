{ lib, pkgs, unstable, config, ... }:
let
  cfg = config.profile.hyprland;
  draw-wallpaper = rec {
    filename = "select-wallpaper.sh";
    script = pkgs.writeScriptBin filename (builtins.readFile ./scripts/draw-wallpaper.sh);
    path = "${script}/bin/${filename}";
  };
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ unstable.pyprland unstable.swww ];
    home.file.".config/hypr/pyprland.toml".source =
      let
        tomlFormat = pkgs.formats.toml { };
      in
      tomlFormat.generate "pyprland.toml" {
        # https://github.com/hyprland-community/pyprland/wiki/Getting-started#configuring
        pyprland.plugins = [
          "scratchpads"
          "fetch_client_menu"
          "wallpapers"
        ];
        scratchpads.term = {
          animation = "fromTop";
          command = "kitty --class kitty-dropterm";
          class = "kitty-dropterm";
          size = "75% 75%";
        };
        wallpapers = {
          path = cfg.pyprland.wallpaper-dirs;
          unique = false;
          command = ''${draw-wallpaper.path} [file]'';
        };
      };
  };
}
