{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.profile.services = {
    caddy.enable = mkEnableOption "caddy";
    cockpit.enable = mkEnableOption "cockpit";
    forgejo.enable = mkEnableOption "forgejo";
    kavita.enable = mkEnableOption "kavita";
    samba.enable = mkEnableOption "samba";
    nextcloud.enable = mkEnableOption "nextcloud";
    syncthing.enable = mkEnableOption "syncthing";
    openvpn.enable = mkEnableOption "openvpn";
    stubby.enable = mkEnableOption "stubby";
    jellyfin.enable = mkEnableOption "jellyfin";
    jellyfin.jellyseerr.enable = mkOption {
      type = types.bool;
      default = config.profile.services.jellyfin.enable;
    };
    rust-motd.enable = mkEnableOption "rust-motd";
    wireguard.enable = mkEnableOption "wireguard";
    photoprism.enable = mkEnableOption "photoprism";
    navidrome.enable = mkEnableOption "navidrome";

    ntfy-sh.enable = mkEnableOption "ntfy-sh";
    ntfy-sh.client.enable = mkOption {
      type = types.bool;
      default = config.profile.services.ntfy-sh.enable;
    };

    telemetry = {
      enable = mkEnableOption "telemetry";
      grafana.enable = mkOption {
        type = types.bool;
        default = config.profile.services.telemetry.enable;
      };
      loki.enable = mkOption {
        type = types.bool;
        default = config.profile.services.telemetry.enable;
      };
      promtail.enable = mkOption {
        type = types.bool;
        default = config.profile.services.telemetry.enable;
      };
      tempo.enable = mkOption {
        type = types.bool;
        default = config.profile.services.telemetry.enable;
      };
      mimir.enable = mkOption {
        type = types.bool;
        default = config.profile.services.telemetry.enable;
      };
      alloy.enable = mkOption {
        type = types.bool;
        default = config.profile.services.telemetry.enable;
      };
    };
  };
}
