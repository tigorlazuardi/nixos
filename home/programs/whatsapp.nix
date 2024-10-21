{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.profile.whatsapp;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.whatsapp-for-linux ];

    wayland.windowManager.hyprland.settings.exec-once = lib.mkIf cfg.autostart [
      "sleep 10; until ${pkgs.unixtools.ping}/bin/ping -c 1 web.whatsapp.com; do sleep 1; done; whatsapp-for-linux"
    ];
  };
}
