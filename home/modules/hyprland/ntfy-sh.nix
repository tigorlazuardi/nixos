{ config, pkgs, lib, ... }:
let
  hyprland = config.profile.hyprland;
  cfg = config.profile.services.ntfy-sh.client;
  inherit (lib) mkIf;
in
{
  config = mkIf (hyprland.enable && cfg.enable) {
    home.packages = with pkgs; [
      ntfy-sh
    ];

    wayland.windowManager.hyprland.settings.exec-once = [
      "ntfy subscribe --config /etc/ntfy/client.yml --from-config"
    ];
  };
}
