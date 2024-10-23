{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.profile.slack;
  autostartScript = pkgs.writeShellScriptBin "slack.sh" ''
    sleep 10; until ${pkgs.unixtools.ping}/bin/ping -c 1 1.1.1.1; do sleep 1; done; slack
  '';
  inherit (lib.meta) getExe;
  autostartScriptFile = getExe autostartScript;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ slack ];

    wayland.windowManager.hyprland.settings.exec-once = lib.mkIf cfg.autostart [ autostartScriptFile ];

    home.file.".config/autostart/slack.sh" = lib.mkIf cfg.autostart { source = autostartScriptFile; };

    services.swaync.settings.scripts._10-slack = {
      app-name = "[Ss]lack";
      exec = "hyprctl dispatch focuswindow Slack";
      run-on = "action";
    };
  };
}
