{ config, lib, pkgs, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    # services.swayosd = {
    #   enable = true;
    #   display = config.profile.hyprland.swayosd.display;
    # };
    home.packages = with pkgs; [
      swayosd
    ];

    wayland.windowManager.hyprland.settings.exec-once = [
      "swayosd-libinput-backend"
      "swayosd-server"
    ];
  };
}
