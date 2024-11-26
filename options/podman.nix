{ config, lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
in
{
  options.profile.podman = {
    enable = lib.mkEnableOption "podman";
    pihole.enable = lib.mkEnableOption "pihole podman";
    ytptube.enable = lib.mkEnableOption "metube podman";
    redmage.enable = lib.mkEnableOption "redmage podman";
    redmage-demo.enable = lib.mkEnableOption "redmage-demo podman";
    qbittorrent.enable = lib.mkEnableOption "qbittorrent podman";
    openobserve.enable = lib.mkEnableOption "openobserve podman";
    minecraft.enable = mkEnableOption "minecraft server podman";
    memos.enable = mkEnableOption "memos podman";
    morphos.enable = mkEnableOption "morphos podman";
    soulseek.enable = mkEnableOption "soulseek podman";
    valheim.enable = mkEnableOption "valheim";

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
      recyclarr.enable = mkOption {
        type = types.bool;
        default = config.profile.podman.servarr.enable;
      };
      rdtclient.enable = mkOption {
        type = types.bool;
        default = config.profile.podman.servarr.enable;
      };
    };
  };
}
