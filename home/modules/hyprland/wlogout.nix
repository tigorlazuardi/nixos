{ lib, config, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.file.".config/wlogout/icons" = {
      source = ./wlogout-icons;
      recursive = true;
    };
    programs.wlogout = {
      style =
        # css
        ''
          /* -----------------------------------------------------
           * Import Pywal colors 
           * ----------------------------------------------------- */
          @import "${config.home.homeDirectory}/.cache/wallust/wlogout.css";

          /* -----------------------------------------------------
           * General 
           * ----------------------------------------------------- */

          * {
            font-family: "Fira Sans Semibold", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
            background-image: none;
            transition: 20ms;
            box-shadow: none;
          }

          window {
            background: url("../../.cache/blurred_wallpaper.png");
            background-size: cover;
          }

          button {
            color: #ffffff;
            font-size: 20px;

            background-repeat: no-repeat;
            background-position: center;
            background-size: 25%;

            border-style: solid;
            background-color: rgba(12, 12, 12, 0.3);
            border: 3px solid #ffffff;

            box-shadow:
              0 4px 8px 0 rgba(0, 0, 0, 0.2),
              0 6px 20px 0 rgba(0, 0, 0, 0.19);
          }

          button:focus,
          button:active,
          button:hover {
            color: @color11;
            background-color: rgba(12, 12, 12, 0.5);
            border: 3px solid @color11;
          }

          /* 
          ----------------------------------------------------- 
          Buttons
          ----------------------------------------------------- 
          */

          #lock {
            margin: 10px;
            border-radius: 20px;
            background-image: image(url("icons/lock.png"));
          }

          #logout {
            margin: 10px;
            border-radius: 20px;
            background-image: image(url("icons/logout.png"));
          }

          #suspend {
            margin: 10px;
            border-radius: 20px;
            background-image: image(url("icons/suspend.png"));
          }

          #hibernate {
            margin: 10px;
            border-radius: 20px;
            background-image: image(url("icons/hibernate.png"));
          }

          #shutdown {
            margin: 10px;
            border-radius: 20px;
            background-image: image(url("icons/shutdown.png"));
          }

          #reboot {
            margin: 10px;
            border-radius: 20px;
            background-image: image(url("icons/reboot.png"));
          }
        '';
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
  };
}
