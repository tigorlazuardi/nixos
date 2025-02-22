{
  lib,
  config,
  unstable,
  pkgs,
  ...
}:
let
  cfg = config.profile.hyprland;
  modules = (pkgs.formats.json { }).generate "modules.json" {
    pulseaudio = {
      format = "{icon}   {volume}%";
      format-blocked = "{volume}%  {icon} {format_source}";
      format-bluetooth-muted = " {icon} {format_source}";
      format-muted = " {format_source}";
      format-source = "{volume}% ";
      format-source-muted = "";
      format-icons = {
        headphone = " ";
        hands-free = " ";
        headset = " ";
        phone = " ";
        portable = " ";
        car = " ";
        default = [
          " "
          " "
          " "
        ];
      };
      on-click = "pavucontrol";
    };
    bluetooth = {
      format = "  {status}";
      format-disabled = "";
      format-off = "";
      interval = 30;
      on-click = "blueman-manager";
      format-no-controller = "";
    };
    battery = {
      states = {
        warning = 30;
        critical = 15;
      };
      format = "{icon}  {capacity}%";
      format-charging = "  {capacity}%";
      format-plugged = "  {capacity}%";
      format-alt = "{icon}  {time}";
      format-icons = [
        " "
        " "
        " "
        " "
        " "
      ];
    };
    network = {
      format = "{ifname}";
      format-wifi = "   {signalStrength}%";
      format-ethernet = "  {ifname}";
      format-disconnected = "Disconnected";
      tooltip-format = " {ifname} via {gwaddri}";
      tooltip-format-wifi = "  {ifname} @ {essid}\nIP: {ipaddr}\nStrength: {signalStrength}%\nFreq: {frequency}MHz\nUp: {bandwidthUpBits} Down: {bandwidthDownBits}";
      tooltip-format-ethernet = " {ifname}\nIP: {ipaddr}\n up: {bandwidthUpBits} down: {bandwidthDownBits}";
      tooltip-format-disconnected = "Disconnected";
      max-length = 50;
      on-click = "nm-connection-editor";
    };

    # "custom/cliphist" = {
    #   format = "";
    #   on-click = ''cliphist list | rofi -dmenu -font "$gui-font" -p "Select item to copy" -lines 10 -width 35 | cliphist decode | wl-copy'';
    #   tooltip = false;
    # };

    "hyprland/workspaces" = {
      on-click = "activate";
      active-only = false;
      all-outputs = false;
      format = "{icon}";
      format-icons = {
        "1" = "1";
        "2" = "2";
        "3" = "3";
        "4" = "4";
        "5" = "  5";
        "6" = "  6";
        "7" = "󰙯  7";
        "8" = "8";
        "9" = "9";
        "10" = "10";
      };
      persistent-workspaces = cfg.waybar.persistent-workspaces;
      ignore-workspaces = [
        ''^-'' # Ignore negatives (Scratchpads takes negavite workspace values).
      ];
    };

    idle_inhibitor = {
      format = "{icon}";
      tooltip = true;
      format-icons = {
        activated = "";
        deactivated = "";
      };
      on-click-right = "hyprlock";
    };

    tray = {
      icon-size = 21;
      spacing = 10;
    };

    clock = {
      format = "{:%H:%M %a}";
      timezone = "Asia/Jakarta";
      tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      format-alt = "{:%Y-%m-%d}";
    };

    "custom/exit" = {
      format = "";
      on-click = "wlogout";
      tooltip = false;
    };

    "hyprland/window" = {
      rewrite = {
        "(.*) - Microsoft Edge$" = "   $1";
        "(.*) - NVIM" = "   $1";
        "^foot$" = "    Foot";
      };
    };

    "custom/notification" = {
      tooltip = false;
      format = "{icon}";
      format-icons = {
        notification = "<span foreground='red'><sup></sup></span>";
        none = "";
        dnd-notification = "<span foreground='red'><sup></sup></span>";
        dnd-none = "";
        inhibited-notification = "<span foreground='red'><sup></sup></span>";
        inhibited-none = "";
        dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
        dnd-inhibited-none = "";
      };
      return-type = "json";
      exec-if = "which swaync-client";
      exec = "swaync-client --subscribe-waybar";
      on-click = "swaync-client --toggle-panel --skip-wait";
      on-click-right = "swaync-client --toggle-dnd --skip-wait";
      escape = true;
    };
  };
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cliphist
      wl-clipboard
      rofi-wayland
    ];
    wayland.windowManager.hyprland.settings.exec-once = [
      "sleep 5 && waybar"
      "wl-paste --watch cliphist store"
    ];
    programs.waybar = {
      package = unstable.waybar;
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          padding-left = 4;
          margin-top = 0;
          margin-bottom = 0;
          margin-left = 0;
          margin-right = 0;
          spacing = 0;
          reload_style_on_change = true;
          include = [ modules ];
          modules-left = [ "hyprland/window" ];
          modules-center = [
            "hyprland/workspaces"
            "custom/notification"
          ];
          modules-right = [
            "pulseaudio"
            "bluetooth"
            "battery"
            "network"
            # "custom/cliphist"
            "idle_inhibitor"
            "tray"
            "custom/exit"
            "clock"
          ];
        };
      };
      # style = ''
      #   @import "${config.home.homeDirectory}/.cache/wallust/waybar.css"  ;
      # '';
    };

    home.file.".config/wallust/templates/waybar.css".text = # css
      ''
        @define-color foreground {{foreground}};
        @define-color background {{background}};
        @define-color cursor {{cursor}};

        @define-color color0 {{color0}};
        @define-color color1 {{color1}};
        @define-color color2 {{color2}};
        @define-color color3 {{color3 | lighten(0.5)}};
        @define-color color4 {{color4}};
        @define-color color5 {{color5}};
        @define-color color6 {{color6}};
        @define-color color7 {{color7}};
        @define-color color8 {{color8}};
        @define-color color9 {{color9}};
        @define-color color10 {{color10}};
        @define-color color11 {{color11}};
        @define-color color12 {{color12}};
        @define-color color13 {{color13}};
        @define-color color14 {{color14}};
        @define-color color15 {{color15}};

        @define-color backgroundlight {{color8}};
        @define-color backgrounddark {{foreground}};
        @define-color workspacesbackground1 {{foreground | darken(0.4)}};
        @define-color workspacesbackground2 {{foreground}};
        @define-color bordercolor {{color8}};
        @define-color textcolor1 {{color8}};
        @define-color textcolor2 {{foreground}};
        @define-color textcolor3 {{foreground}};
        @define-color iconcolor {{foreground}};

        @define-color group-background-color rgba({{color2 | rgb}}, 0.3);
        @define-color group-border-color rgba({{foreground | rgb}}, 0.8);
        @define-color tooltip-background-color rgba({{color1 | rgb}}, 0.95);
        @define-color text-base {{foreground}};
        @define-color text-alt {{color8}};

        * {
            font-family: "Fira Sans Semibold", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
            border: none;
            border-radius: 0px;
        }

        window#waybar {
            background-color: rgba({{background | rgb}}, 0.3);
            border: 0px;
            color: {{foreground}};
            transition-property: background-color;
            transition-duration: 0.5s;
        }

        /* -----------------------------------------------------
        * Workspaces 
        * ----------------------------------------------------- */

        #workspaces {
            background: @group-background-color;
            margin: 5px 1px 6px 1px;
            padding: 0px 0.75rem;
            border-radius: 24px;
            border: 2px solid @group-border-color;
            font-weight: bold;
            font-style: normal;
            font-size: 16px;
        }

        #workspaces button {
            padding: 0px 5px;
            margin: 4px 3px;
            border-radius: 15px;
            border: 0px;
            color: @textcolor1;
            background-color: @workspacesbackground2;
            transition: all 0.3s ease-in-out;
        }

        #workspaces button.active {
            color: @textcolor1;
            background: @workspacesbackground2;
            border-radius: 15px;
            min-width: 40px;
            transition: all 0.3s ease-in-out;
            opacity: 1;
        }

        #workspaces button:hover {
            color: @textcolor1;
            background: @workspacesbackground2;
            border-radius: 15px;
            opacity: 0.7;
        }

        /* -----------------------------------------------------
        * Tooltips
        * ----------------------------------------------------- */

        tooltip {
            border-radius: 10px;
            background-color: @tooltip-background-color;
            padding: 20px;
            margin: 0px;
            border: 1px solid @textcolor2;
        }

        tooltip label {
            color: @textcolor2;
        }

        /* -----------------------------------------------------
        * Window
        * ----------------------------------------------------- */

        #window {
            background: @group-background-color;
            border: 2px solid @group-border-color;
            margin: 8px 15px 8px 0px;
            padding: 2px 10px 0px 10px;
            border-radius: 12px;
            color: @textcolor2;
            font-size: 16px;
            font-weight: normal;
        }

        window#waybar.empty #window {
            background-color: transparent;
            border: 0px;
        }

        /* -----------------------------------------------------
        * Taskbar
        * ----------------------------------------------------- */

        #taskbar {
            background: @backgroundlight;
            margin: 6px 15px 6px 0px;
            padding: 0px;
            border-radius: 15px;
            font-weight: normal;
            font-style: normal;
            opacity: 0.8;
            border: 3px solid @backgroundlight;
        }

        #taskbar button {
            margin: 0;
            border-radius: 15px;
            padding: 0px 5px 0px 5px;
        }

        /* -----------------------------------------------------
        * Modules
        * ----------------------------------------------------- */

        .modules-left {
            padding-left: 1rem;
        }

        .modules-left > widget:first-child > #workspaces {
            margin-left: 0;
        }

        .modules-right > widget:last-child > #workspaces {
            margin-right: 0;
        }

        /* -----------------------------------------------------
        * Custom Quicklinks
        * ----------------------------------------------------- */

        #custom-brave,
        #custom-browser,
        #custom-keybindings,
        #custom-outlook,
        #custom-filemanager,
        #custom-teams,
        #custom-chatgpt,
        #custom-calculator,
        #custom-windowsvm,
        #custom-cliphist,
        #custom-wallpaper,
        #custom-settings,
        #custom-wallpaper,
        #custom-system,
        #custom-waybarthemes {
            margin-right: 23px;
            font-size: 20px;
            font-weight: bold;
            opacity: 0.8;
            color: @iconcolor;
        }

        #custom-system {
            margin-right: 15px;
        }

        #custom-wallpaper {
            margin-right: 25px;
        }

        #custom-waybarthemes,
        #custom-settings {
            margin-right: 20px;
        }

        #custom-ml4w-welcome {
            margin-right: 12px;
            background-image: url("../assets/ml4w-icon.png");
            background-repeat: no-repeat;
            background-position: center;
            padding-right: 24px;
        }

        #custom-ml4w-hyprland-settings {
            margin-right: 12px;
            background-image: url("../assets/hyprland-icon.png");
            background-repeat: no-repeat;
            background-position: center;
            padding-right: 16px;
        }

        #custom-chatgpt {
            margin-right: 12px;
            background-image: url("../assets/ai-icon-20.png");
            background-repeat: no-repeat;
            background-position: center;
            padding-right: 24px;
        }

        /* -----------------------------------------------------
                * Idle Inhibator
                * ----------------------------------------------------- */

        #idle_inhibitor {
            margin-right: 17px;
            font-size: 20px;
            font-weight: bold;
            opacity: 0.8;
            color: @iconcolor;
        }

        #idle_inhibitor.activated {
            margin-right: 15px;
            font-size: 20px;
            font-weight: bold;
            opacity: 0.8;
            color: #dc2f2f;
        }

        /* -----------------------------------------------------
        * Custom Modules
        * ----------------------------------------------------- */

        #custom-appmenu {
            background-color: @backgrounddark;
            font-size: 16px;
            color: @textcolor1;
            border-radius: 15px;
            padding: 0px 10px 0px 10px;
            margin: 8px 14px 8px 14px;
            opacity: 0.8;
            border: 3px solid @bordercolor;
        }

        /* -----------------------------------------------------
        * Custom Exit
        * ----------------------------------------------------- */

        #custom-exit {
            margin: 0px 20px 0px 0px;
            padding: 0px;
            font-size: 20px;
            color: @iconcolor;
        }

        /* -----------------------------------------------------
        * Clock
        * ----------------------------------------------------- */

        #clock {
            background-color: @group-background-color;
            font-size: 16px;
            color: @text-base;
            border-radius: 15px;
            padding: 1px 10px 0px 10px;
            margin: 8px 15px 8px 0px;
            border: 3px solid @group-border-color;
        }

        /* -----------------------------------------------------
        * Pulseaudio
        * ----------------------------------------------------- */

        #pulseaudio {
            background-color: @group-background-color;
            font-size: 16px;
            border: 2px solid @group-border-color;
            color: @textcolor2;
            border-radius: 15px;
            padding: 2px 10px 0px 10px;
            margin: 8px 15px 8px 0px;
        }

        #pulseaudio.muted {
            color: @color3;
            border-color: @color3;
        }

        /* -----------------------------------------------------
        * Network
        * ----------------------------------------------------- */

        #network {
            background-color: @group-background-color;
            border: 2px solid @group-border-color;
            font-size: 16px;
            color: @text-base;
            border-radius: 15px;
            padding: 2px 10px 0px 10px;
            margin: 8px 15px 8px 0px;
        }

        /* -----------------------------------------------------
                * Bluetooth
                * ----------------------------------------------------- */

        #bluetooth,
        #bluetooth.on,
        #bluetooth.connected {
            background-color: @group-background-color;
            border: 2px solid @group-border-color;
            font-size: 16px;
            color: @text-base;
            border-radius: 15px;
            padding: 2px 10px 0px 10px;
            margin: 8px 15px 8px 0px;
        }

        #bluetooth.off {
            background-color: transparent;
            padding: 0px;
            margin: 0px;
        }

        /* -----------------------------------------------------
        * Battery
        * ----------------------------------------------------- */

        #battery {
            background-color: @group-background-color;
            border: 2px solid @group-border-color;
            font-size: 16px;
            color: @text-base;
            border-radius: 15px;
            padding: 2px 15px 0px 10px;
            margin: 8px 15px 8px 0px;
            opacity: 0.8;
        }

        #battery.charging,
        #battery.plugged {
            color: @text-base;
        }

        @keyframes blink {
            to {
            background-color: @backgroundlight;
            color: @textcolor2;
            }
        }

        #battery.critical:not(.charging) {
            background-color: #f53c3c;
            color: @textcolor3;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        /* -----------------------------------------------------
        * Tray
        * ----------------------------------------------------- */

        #tray {
            padding: 0px 15px 0px 0px;
            color: @textcolor3;
        }

        #tray > .passive {
            -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
            -gtk-icon-effect: highlight;
        }

        #custom-notification {
          font-family: "NotoSansMono Nerd Font";
          margin-right: 20px;
          margin-left: 20px;
          font-size: 20px;
          font-weight: bold;
          opacity: 0.8;
          color: @iconcolor;
        }
      '';

    profile.hyprland.wallust.settings.templates.waybar =
      let
        out = config.home.homeDirectory + "/.cache/wallust";
      in
      {
        template = "waybar.css";
        target = out + "/waybar.css";
      };

  };

}
