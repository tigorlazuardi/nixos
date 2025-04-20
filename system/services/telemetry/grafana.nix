{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.telemetry.grafana;
  inherit (lib) mkIf;
  name = "grafana";
  grafanaDomain = "${name}.tigor.web.id";
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

    services.caddy.virtualHosts.${grafanaDomain}.extraConfig = ''
      reverse_proxy ${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}
    '';

    services.nginx.virtualHosts.${grafanaDomain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://unix:/run/anubis/anubis-${name}.sock";
        proxyWebsockets = true;
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [
      grafanaDomain
    ];

    services.anubis.instances."${name}".settings = {
      TARGET =
        let
          server = config.services.grafana.settings.server;
        in
        "http://${server.http_addr}:${toString server.http_port}";
    };

    services.adguardhome.settings.user_rules = [
      "192.168.100.5 ${grafanaDomain}"
    ];

    environment.etc."alloy/config.alloy".text =
      # hocon
      ''
        prometheus.scrape "anubis_${name}" {
            targets     = [{
              __address__ = "127.0.0.1:33002",
            }]
            job_name   = "anubis_${name}"
            forward_to  = [prometheus.remote_write.mimir.receiver]
        }
      '';

    services.grafana = {
      enable = true;
      package = pkgs.grafana;
      settings = {
        # https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/
        server = {
          protocol = "http"; # served behind caddy
          http_addr = "0.0.0.0";
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
