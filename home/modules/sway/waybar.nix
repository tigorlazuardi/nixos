{ config, lib, unstable, ... }:
let
  cfg = config.profile.sway;
in
{
  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      style = ./waybar.css;
      systemd.enable = true;
      package = unstable.waybar;
    };

    programs.waybar.settings = {
      main = {
        layer = "top";
        position = "bottom";
        spacing = 0;
        margin-bottom = 0;
        margin-left = 300;
        margin-right = 300;
        modules-left = [
          "sway/workspaces"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "tray"
          "network"
          "battery"
          "pulseaudio"
        ];

        "sway/taskbar" = {
          format = "{icon}";
          on-click = "activate";
          on-click-right = "fullscreen";
          icon-size = 25;
          tooltip-format = "{title}";
        };

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
          };
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
        };

        tray.spacing = 10;
        clock.format = "{:%I:%M %p - %a, %d %b %Y}";
        network = {
          format-wifi = "{icon}";
          format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
          format-ethernet = "";
          format-disconnected = "󰤮";
          interval = 5;
        };

        pulseaudio = {
          scroll-step = 5;
          max-volume = 150;
          format = "{icon} {volume}%";
          format-bluetooth = "󰂰";
          nospacing = 1;
          format-muted = "󰝟";
          format-icons = {
            headphone = "";
            default = [ "" "" " " ];
          };
          on-click = "pamixer -t";
        };

        battery = {
          format = "{icon} {capacity}%";
          format-icons = {
            charging = [ "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅" ];
            default = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          };
          format-full = "Charged ";
          interval = 5;
          states = {
            warning = 20;
            critical = 10;
          };
          tooltip = false;
        };
      };
    };
  };
}
