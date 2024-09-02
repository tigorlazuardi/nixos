{ lib, config, ... }:
let
  types = lib.types;
in
{
  options.profile.hyprland = {
    enable = lib.mkEnableOption "hyperland";
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
      type = lib.types.enum [ "sddm" "tuigreet" ];
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

    wallust = {
      backend = lib.mkOption {
        type = lib.types.enum [ "full" "resized" "wal" "thumb" "fastresize" "kmeans" ];
        default = "kmeans";
        description = "How the image is parse, in order to get the colors";
      };
      colorSpace = lib.mkOption {
        type = lib.types.enum [ "lab" "labmixed" "lch" "lchmixed" ];
        default = "lch";
        description = "What color space to use to produce and select the most prominent colors";
      };
      alpha = lib.mkOption {
        type = lib.types.int;
        default = 100;
      };
      threshold = lib.mkOption {
        type = lib.types.int;
        default = 1;
      };
      palette = lib.mkOption {
        type = lib.types.enum [
          "dark"
          "dark16"
          "darkcomp"
          "darkcomp16"
          "light"
          "light16"
          "lightcomp"
          "lightcomp16"
          "harddark"
          "harddark16"
          "harddarkcomp"
          "harddarkcomp16"
          "softdark"
          "softdark16"
          "softdarkcomp"
          "softdarkcomp16"
          "softlight"
          "softlight16"
          "softlightcomp"
          "softlightcomp16"
        ];
        default = "dark";
        description = ''Use the most prominent colors in a way that makes sense. A Scheme color palette.'';
      };
      checkContrast = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };
}
