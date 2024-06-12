{ lib, config, unstable, pkgs, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.btop ];
    home.file.".config/waybar/modules.jsonc".source = ./waybar-modules.jsonc;
    home.file.".config/waybar/hyprland.jsonc".text = builtins.toJSON {
      "hyprland/workspaces" = {
        "on-click" = "activate";
        "active-only" = false;
        "all-outputs" = false;
        "format" = "{icon}";
        "format-icons" = {
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
        "persistent-workspaces" = cfg.waybar.persistent-workspaces;
        "ignore-workspaces" = [
          ''^-'' # Ignore negatives (Scratchpads takes negavite workspace values).
        ];
      };
    };
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
          include = [
            "~/.config/waybar/modules.jsonc"
            "~/.config/waybar/hyprland.jsonc"
          ];
          modules-left = [
            "group/quicklinks"
            "hyprland/window"
          ];
          modules-center = [
            "hyprland/workspaces"
          ];
          modules-right = [
            "pulseaudio"
            "bluetooth"
            "battery"
            "network"
            "group/hardware"
            "custom/cliphist"
            "idle_inhibitor"
            "tray"
            "custom/exit"
            "clock"
          ];
        };
      };
      # style = ''
      #   @import "${config.home.homeDirectory}/.cache/wallust/waybar.css";
      # '';
    };
  };
}
