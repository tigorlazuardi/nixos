{ config, lib, pkgs, ... }:
let
  cfg = config.profile.services.telemetry;
  inherit (lib) mkIf;
  grafanaDomain = "grafana.tigor.web.id";
in
{
  config = mkIf cfg.enable {
    sops.secrets =
      let
        opts = { sopsFile = ../../secrets/telemetry.yaml; owner = "grafana"; };
      in
      mkIf cfg.grafana.enable {
        "grafana/admin_user" = opts;
        "grafana/admin_password" = opts;
        "grafana/admin_email" = opts;
        "grafana/secret_key" = opts;
      };

    services.caddy.virtualHosts.${grafanaDomain}.extraConfig = mkIf cfg.grafana.enable ''
      reverse_proxy ${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}
    '';

    services.grafana = mkIf cfg.grafana.enable {
      enable = true;
      package = pkgs.grafana;
      settings = {
        # https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/
        server = {
          protocol = "http"; # served behind caddy
          http_addr = "0.0.0.0";
          http_port = 44518;
          domain = grafanaDomain;
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
