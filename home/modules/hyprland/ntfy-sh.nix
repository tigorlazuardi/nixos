{ config, pkgs, lib, ... }:
let
  hyprland = config.profile.hyprland;
  cfg = config.profile.services.ntfy-sh.client;
  inherit (lib) mkIf;
in
{
  config = mkIf (hyprland.enable && cfg.enable) {
    wayland.windowManager.hyprland.settings.exec-once = [
      "${pkgs.ntfy-sh}/bin/ntfy subscribe --config /etc/ntfy/client.yml --from-config"
    ];
  };
}
