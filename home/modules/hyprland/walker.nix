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
        hotreload_theme = true;
        builtins.windows.weight = 100;
        plugins = [
          {
            name = "projects";
            placeholder = "Projects";
            show_icon_when_single = true;
            src_once = "zoxide query --list";
            weight = 20;
            cmd = # sh
              ''footclient --title="Project: %RESULT%" --working-directory="%RESULT%"'';
          }
        ];
        keys = {
          next = [
            "down"
            "ctrl n"
          ];
          prev = [
            "up"
            "ctrl p"
          ];
          accept_typeahead = [
            "tab"
            "ctrl y"
          ];
        };
      };
    };

    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mod, S, exec, walker"
      ];
    };
  };
}
