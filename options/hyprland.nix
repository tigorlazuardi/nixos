{
  lib,
  pkgs,
  config,
  ...
}:
let
  types = lib.types;
  inherit (lib) mkOption;
in
{
  options.profile.hyprland = {
    enable = lib.mkEnableOption "hyperland";
    xdgPortal =
      let
        format = pkgs.formats.ini { };
      in
      mkOption {
        type = types.submodule {
          freeformType = format.type;
          options = {
            preferred = {
              default = mkOption {
                type = types.str;
                default = "hyprland;gtk";
              };
            };
          };
        };
        default = { };
        description = ''
          Options to pass to xdg-desktop-portal-hyprland.conf.

          Can be used to set notification inhibitions or change file pickers.

          See: https://wiki.hyprland.org/hyprland-wiki/pages/Useful-Utilities/Hyprland-desktop-portal/
        '';
      };

    postDraw = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Post Draw shell script to run after drawing the wallpaper.

        4 variables are in the scope of this script:

        - $image_file: The path to the original image file
        - $target: The path to the current wallpaper
        - $blur_target: The path to the blurred wallpaper
        - $square_target: The path to the square wallpaper
      '';
    };
    settings = {
      monitors = lib.mkOption {
        type = with types; listOf str;
        default = [ ];
        description = ''List of monitors hyprland should manage'';
        example = ''[ ",preffered,auto,1" ]'';
      };
      workspaces = lib.mkOption {
        type = with types; listOf str;
        default = [ ];
        description = ''List of workspaces to create'';
        example = ''[ "1,default:true" "2" "3" "4" "5" "6" "7" "8" "9" "10" ]'';
      };
    };

    displayManager = lib.mkOption {
      type = lib.types.enum [
        "sddm"
        "tuigreet"
      ];
      default = "tuigreet";
    };

    swayosd.display = lib.mkOption {
      type = lib.types.str;
      default = "eDP-1";
    };
    waybar.persistent-workspaces = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''List of hyprland workspaces to keep in waybar, in the format of { [monitor] = [workspace] }'';
      example = ''
        {
            DP-1 = [ 1 2 3 4 5 6 7];
            DP-1 = [ 8 9 10 ];
        }
      '';
    };

    pyprland = {
      wallpaper-dirs = lib.mkOption {
        type = with types; listOf str;
        default = [ ];
        description = ''List of directories to search for wallpapers'';
      };
    };

    hypridle = {
      lockTimeout = lib.mkOption {
        type = lib.types.int;
        default = 600;
        description = ''Time in seconds before the screen locks'';
      };
      dpmsTimeout = lib.mkOption {
        type = lib.types.int;
        default = config.profile.hyprland.hypridle.lockTimeout + 60;
        description = ''Time in seconds before the screen turns off. default is lockTimeout + 60'';
      };
      suspendTimeout = lib.mkOption {
        type = lib.types.int;
        default = 1800;
        description = ''Time in seconds before the system suspends. default is 30 minutes (1800 seconds)'';
      };
    };

    dunst.monitor = lib.mkOption {
      type = lib.types.str;
      default = "0";
    };

    wallust.settings = lib.mkOption {
      type = (pkgs.formats.toml { }).type;
      default = { };
    };
  };
}
