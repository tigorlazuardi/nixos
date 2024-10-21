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

    "custom/cliphist" = {
      format = "";
      on-click = ''cliphist list | rofi -dmenu -font "$gui-font" -p "Select item to copy" -lines 10 -width 35 | cliphist decode | wl-copy'';
      tooltip = false;
    };

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
      "sleep 1 && waybar"
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
            "custom/cliphist"
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
  };
}
