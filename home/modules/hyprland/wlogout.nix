{ lib, config, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    # catppuccin.wlogout.extraStyle = # css
    #   ''
    #     #lock {
    #       background-image: image(url("${./wlogout-icons/lock.png}"));
    #     }
    #
    #     #logout {
    #       background-image: image(url("${./wlogout-icons/logout.png}"));
    #     }
    #
    #     #suspend {
    #       background-image: image(url("${./wlogout-icons/suspend.png}"));
    #     }
    #
    #     #hibernate {
    #       background-image: image(url("${./wlogout-icons/hibernate.png}"));
    #     }
    #
    #     #shutdown {
    #       background-image: image(url("${./wlogout-icons/shutdown.png}"));
    #     }
    #
    #     #reboot {
    #       background-image: image(url("${./wlogout-icons/reboot.png}"));
    #     }
    #   '';
    programs.wlogout = {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "loginctl lock-session";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "hibernate";
          action = "sleep 1; systemctl hibernate";
          text = "Hibernate";
          keybind = "h";
        }
        {
          label = "logout";
          # According to the docs at https://github.com/Vladimir-csp/uwsm#how-to-stop
          # There are 4 ways to stop the session. While using `loginctl terminate-user ""`
          # seems to be the most thorough, it also seems to be the very aggressive option with the
          # graphical glitches found when exiting the session.
          #
          # The `uwsm stop` is ideal, since this repo is single user / seat, so exiting the
          # uwsm session will stop the login session, meaning all session data will be restarted on login anyway.
          # This is the most graceful logout since it is handled by uwsm itself.
          action = "uwsm stop";
          text = "Exit";
          keybind = "e";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "Suspend";
          keybind = "u";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
      ];
    };
    profile.hyprland.wallust.settings.templates.wlogout =
      let
        out = config.home.homeDirectory + "/.cache/wallust";
      in
      {
        template = "wlogout.css";
        target = out + "/wlogout.css";
      };
  };
}
