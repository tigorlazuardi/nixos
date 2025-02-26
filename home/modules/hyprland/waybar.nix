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
          tray = {
            spacing = 10;
            icon-size = 21;
          };
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
      style =
        # css
        ''
          * {
              font-family: "Fira Sans Semibold", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
              border: none;
              border-radius: 0px;
              color: @text;
          }

          window#waybar {
            background: alpha(@base, 0.6);
            padding-right: 0;
            margin-right: 0;
          }


          #workspaces {
            margin: 0 0.4rem;
            padding: 0 0.4rem;
            margin-left: 1rem;
          }

          #workspaces button {
            padding: 0.4rem 0.4rem;
            font-weight: bold;
            transition: all 0.2s ease-in-out;
          }

          #workspaces button.active {
            padding: 0 0.8rem;
            border: 2px solid @maroon;
            background-color: alpha(@blue, 0.4);
            border-style: none none solid none;
          }

          #workspaces button:hover {
            padding: 0 0.8rem;
            margin: 0;
            border: 2px solid @blue;
            background: alpha(@maroon, 0.4);
            border: 0;
            border-style: none;
          }

          tooltip {
              border-radius: 1rem;
              background-color: alpha(@base, 0.7);
              padding: 2rem;
              margin: 0px;
              border: 1px solid @overlay2;
          }

          tooltip label {
              color: @rosewater;
              font-size: 0.9rem;
          }

          /* Window Title */

          #window {
              background: linear-gradient(90deg, alpha(@maroon, 0.8) 0%, alpha(@maroon, 0.5) 35%, alpha(@maroon, 0) 100%);
              margin: 0 0;
              padding: 0 0.4rem;
              color: @text;
              font-size: 0.9rem;
              font-weight: bold;
          }

          window#waybar.empty #window {
              background-color: transparent;
          }

          #idle_inhibitor {
              margin-right: 1rem;
              font-size: 1.3rem;
              font-weight: bold;
              opacity: 0.8;
              color: @text;
          }

          #idle_inhibitor.activated {
              margin-right: 1rem;
              font-size: 1.3rem;
              font-weight: bold;
              opacity: 0.8;
              color: @maroon;
          }

          #custom-exit {
              margin-right: 1rem;
              padding: 0 0.5rem;
              font-size: 1.3rem;
              color: @text;
          }


          #clock {
              background: linear-gradient(90deg, alpha(@blue, 0) 0%, alpha(@blue, 0.5) 65%, alpha(@blue, 1) 100%);
              font-size: 1.1rem;
              color: @text;
              margin-top: 0;
              margin-bottom: 0;
              padding: 0.4rem;
              font-weight: bold;
          }

          #pulseaudio {
              background-color: transparent;
              font-size: 1rem;
              color: @text;
              margin-right: 0.3rem;
          }

          #pulseaudio.muted {
              color: @maroon;
          }

          #bluetooth,
          #bluetooth.on,
          #bluetooth.connected {
              font-size: 1rem;
              color: @text;
              margin-right: 0.7rem;
          }

          #bluetooth.off {
              background-color: transparent;
              padding: 0px;
              margin: 0px;
          }


          #battery {
              font-size: 1rem;
              color: @text;
              margin-right: 1rem;
          }

          #battery.charging,
          #battery.plugged {
              color: @text-base;
          }


          @keyframes blink {
              to {
                background-color: @blue;
                color: @maroon;
              }
          }

          #battery.critical:not(.charging) {
              background-color: @red;
              color: @text;
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
          }

          #network {
            color: @text;
            margin-right: 1rem;
            font-size: 1rem;
          }

          #tray {
              color: @text;
              margin-right: 0.5rem;
          }

          #tray > .passive {
              -gtk-icon-effect: dim;
          }

          #tray > .needs-attention {
              -gtk-icon-effect: highlight;
          }

          #custom-notification {
            font-family: "NotoSansMono Nerd Font";
            margin-right: 1rem;
            margin-left: 1rem;
            font-size: 1.3rem;
            color: @text;
          }
        '';
    };

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
