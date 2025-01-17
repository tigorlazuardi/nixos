{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.hyprland;
  inherit (lib.meta) getExe;
in
{
  config = lib.mkIf cfg.enable {
    programs.walker = {
      enable = true;
      runAsService = true;
      config = {
        builtins.websearch.prefix = "?";
        hotreload_theme = true;
        plugins = [
          {
            name = "power";
            placeholder = "Power";
            switcher_only = true;
            recalculate_score = true;
            show_icon_when_single = true;
            prefix = "!";
            entries = [
              {
                label = "Shutdown";
                icon = "system-shutdown";
                exec = "shutdown now";
              }
              {
                label = "Reboot";
                icon = "system-reboot";
                exec = "reboot";
              }
              {
                label = "Lock Screen";
                icon = "system-lock-screen";
                exec = "${getExe pkgs.playerctl} --all-players pause & hyprlock";
              }
            ];
          }
        ];
      };
    };

    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mod, S, exec, walker"
      ];
    };
  };
}
