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
          action = "hyprctl dispatch exit";
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
