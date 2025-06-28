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
    ollama.enable = mkEnableOption "ollama";
    ollama.model = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    adguardhome.enable = mkEnableOption "adguardhome";
    mailcatcher.enable = mkEnableOption "mailcatcher";
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
    immich.enable = mkEnableOption "immich";
    jellyfin.enable = mkEnableOption "jellyfin";
    stirling-pdf.enable = mkEnableOption "stirling-pdf";
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
    github-runner.enable = mkEnableOption "github-runner";
    homepage-dashboard.enable = mkEnableOption "homepage-dashboard";
    authelia.enable = mkEnableOption "authelia";
    flaresolverr = {
      enable = mkEnableOption "flaresolverr";
      domain = mkOption {
        type = types.str;
        default = "flaresolverr.podman";
      };
      ip = mkOption {
        type = types.str;
        default = "10.88.100.100";
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
