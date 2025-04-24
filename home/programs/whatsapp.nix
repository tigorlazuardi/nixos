{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.profile.whatsapp;
  autostartScript = pkgs.writeShellScriptBin "whatsapp.sh" ''
    sleep 10; until ${pkgs.unixtools.ping}/bin/ping -c 1 google.com; do sleep 1; done; ${lib.meta.getExe pkgs.wasistlos}
  '';
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.wasistlos ];

    wayland.windowManager.hyprland.settings.exec-once = lib.mkIf cfg.autostart [
      "${lib.meta.getExe autostartScript}"
    ];

    home.file.".config/autostart/whatsapp.sh" = lib.mkIf cfg.autostart {
      source = "${lib.meta.getExe autostartScript}";
    };

    services.swaync.settings.scripts._10-whatsapp = {
      app-name = "wasistlos";
      exec = "hyprctl dispatch focuswindow wasistlos";
      run-on = "action";
    };
  };
}
