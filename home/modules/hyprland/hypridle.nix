{ lib, config, unstable, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ unstable.hypridle ];

    home.file.".config/hypr/hypridle.conf".text = /*hyprlang*/ ''
      general {
        lock_cmd = "pidof hyprlock || hyprlock"
        before_sleep_cmd = "hyprlock"
        after_sleep_cmd = hyprctl dispatch dpms on
      }

      listener {
        timeout = ${toString cfg.hypridle.lockTimeout}
        on-timeout = "hyprlock"
      }

      listener {
        timeout = ${toString cfg.hypridle.dpmsTimeout}
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
      }

      listener {
        timeout = ${toString cfg.hypridle.suspendTimeout}
        on-timeout = systemctl suspend
      }
    '';
  };
}
