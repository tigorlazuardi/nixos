{ config, lib, ... }:
let
  cfg = config.profile.gnome;
in
{
  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
        defaultSession = "gnome";
      };
      desktopManager.gnome.enable = true;
    };
    services.gnome.gnome-browser-connector.enable = true;
  };
}
