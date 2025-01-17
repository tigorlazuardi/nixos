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
    home.packages = with pkgs; [ walker ];

    home.file.".config/walker/config.json".source =
      (pkgs.formats.json { }).generate ''walker-config.json''
        {
          hotreload_theme = true;
          plugins = [
            {
              name = "power";
              placeholder = "Power";
              switcher_only = true;
              recalculate_score = true;
              show_icon_when_single = true;
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

    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "walker --gapplication-service"
      ];
      bind = [
        "$mod, S, exec, walker"
      ];
    };
  };
}
