{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.telemetry.grafana;
  inherit (lib) mkIf;
  grafanaDomain = "grafana.tigor.web.id";
in
{
  config = mkIf cfg.enable {
    sops.secrets =
      let
        opts = {
          sopsFile = ../../../secrets/telemetry.yaml;
          owner = "grafana";
        };
      in
      {
        "grafana/admin_user" = opts;
        "grafana/admin_password" = opts;
        "grafana/admin_email" = opts;
        "grafana/secret_key" = opts;
      };

    services.nginx.virtualHosts.${grafanaDomain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://unix:${config.services.anubis.instances.grafana.settings.BIND}";
        proxyWebsockets = true;
      };
    };

    services.anubis.instances.grafana.settings.TARGET =
      "unix://${config.systemd.socketActivations.grafana.socketAddress}";

    systemd.socketActivations.grafana =
      let
        inherit (config.services.grafana.settings.server) http_addr http_port;
      in
      {
        host = http_addr;
        port = http_port;
      };

    services.grafana = {
      enable = true;
      package = pkgs.grafana;
      settings = {
        # https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/
        server = {
          protocol = "http";
          http_addr = "127.0.0.1";
          http_port = 44518;
          root_url = "https://${grafanaDomain}";
          enable_gzip = true;
        };
        database = {
          type = "sqlite3";
          cache_mode = "shared";
          wal = true;
          query_retries = 3;
        };
        security = {
          # Admin credentials is already available in the secrets
          admin_user = "$__file{${config.sops.secrets."grafana/admin_user".path}}";
          admin_password = "$__file{${config.sops.secrets."grafana/admin_password".path}}";
          admin_email = "$__file{${config.sops.secrets."grafana/admin_email".path}}";
          secret_key = "$__file{${config.sops.secrets."grafana/secret_key".path}}";
          cookie_secure = true;
          cookie_samesite = "lax";
          strict_transport_security = true;
        };
      };
    };
  };
}
