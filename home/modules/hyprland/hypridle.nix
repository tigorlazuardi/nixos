{ lib, config, unstable, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ unstable.hypridle ];

    home.file.".config/hypr/hypridle.conf".text = ''
      general {
        lock_cmd = "pidof hyprlock || hyprlock"
        before_sleep_cmd = "hyprlock"
        after_sleep_cmd = hyprctl dispatch dpms on
      }

      listener {
        timeout = 600
        on-timeout = "hyprlock"
      }

      listener {
        timeout = 660
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
      }

      listener {
        timeout = 1800
        on-timeout = systemctl suspend
      }
    '';
  };
}
