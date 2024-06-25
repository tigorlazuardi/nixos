{ config, lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
in
{
  options.profile.podman = {
    enable = lib.mkEnableOption "podman";
    caddy.enable = lib.mkEnableOption "caddy podman";
    pihole.enable = lib.mkEnableOption "pihole podman";
    suwayomi.enable = lib.mkEnableOption "suwayomi podman";
    ytptube.enable = lib.mkEnableOption "metube podman";
    redmage.enable = lib.mkEnableOption "redmage podman";
    redmage-demo.enable = lib.mkEnableOption "redmage-demo podman";
    qbittorrent.enable = lib.mkEnableOption "qbittorrent podman";

    servarr = {
      enable = mkEnableOption "servarr group";
      qbittorrent.enable = mkOption {
        type = types.bool;
        default = config.profile.podman.servarr.enable;
      };
      real-debrid-manager.enable = mkOption {
        type = types.bool;
        default = config.profile.podman.servarr.enable;
      };
      prowlarr.enable = mkOption {
        type = types.bool;
        default = config.profile.podman.servarr.enable;
      };
      radarr.enable = mkOption {
        type = types.bool;
        default = config.profile.podman.servarr.enable;
      };
      sonarr.enable = mkOption {
        type = types.bool;
        default = config.profile.podman.servarr.enable;
      };
      bazarr.enable = mkOption {
        type = types.bool;
        default = config.profile.podman.servarr.enable;
      };
    };
  };
}
