{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.profile.services = {
    ollama.models = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    adguardhome.enable = mkEnableOption "adguardhome";
    caddy.enable = mkEnableOption "caddy";
    nginx.enable = mkEnableOption "nginx";
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
    resolved.enable = mkEnableOption "resolved";
    rust-motd.enable = mkEnableOption "rust-motd";
    wireguard.enable = mkEnableOption "wireguard";
    photoprism.enable = mkEnableOption "photoprism";
    navidrome.enable = mkEnableOption "navidrome";
    suwayomi.enable = mkEnableOption "suwayomi";
    flaresolverr = {
      enable = mkEnableOption "flaresolverr";
      domain = mkOption {
        type = types.str;
        default = "flaresolverr.tigor.web.id";
      };
    };

    ntfy-sh.enable = mkEnableOption "ntfy-sh";
    ntfy-sh.client = {
      settings = lib.mkOption {
        type = (pkgs.formats.yaml { }).type;
        default = { };
      };
      enable = mkOption {
        type = types.bool;
        default = config.profile.services.ntfy-sh.enable;
      };
    };

    redis = {
      client.cli.enable = mkEnableOption "redis cli client";
    };

    couchdb.enable = mkEnableOption "couchdb";

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
      prometheus.enable = mkOption {
        type = types.bool;
        default = config.profile.services.telemetry.enable;
      };
    };
    technitium.enable = mkEnableOption "technitium";
  };
}
