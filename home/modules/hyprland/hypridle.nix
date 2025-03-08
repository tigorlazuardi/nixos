{
  lib,
  config,
  ...
}:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout = cfg.hypridle.lockTimeout;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = cfg.hypridle.dpmsTimeout;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = cfg.hypridle.suspendTimeout;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
    # uwsm affects when the WAYLAND_DISPLAY environment is set.
    # It's a pain to manage this with systemd, so we'll just ignore the
    # systemd check condirion.
    systemd.user.services.hypridle.Unit.ConditionEnvironment = lib.mkForce [ ];
  };
}
