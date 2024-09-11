{ config, lib, ... }:
let
  cfg = config.profile.services.telemetry.loki;
  inherit (lib) mkIf;
  lokiDomain = "loki.tigor.web.id";
  server = config.services.loki.configuration.server;
in
{
  config = mkIf cfg.enable {
    sops =
      let
        usernameKey = "loki/caddy/basic_auth/username";
        passwordKey = "loki/caddy/basic_auth/password";
      in
      {
        secrets =
          let
            opts = { sopsFile = ../../../secrets/telemetry.yaml; owner = "grafana"; };
          in
          {
            ${usernameKey} = opts;
            ${passwordKey} = opts;
          };
        templates = {
          "loki/caddy/basic_auth".content = /*sh*/ ''
            LOKI_USERNAME=${config.sops.placeholder.${usernameKey}}
            LOKI_PASSWORD=${config.sops.placeholder.${passwordKey}}
          '';
        };
      };

    systemd.services."caddy".serviceConfig = {
      EnvironmentFile = [ config.sops.templates."loki/caddy/basic_auth".path ];
    };
    services.caddy.virtualHosts.${lokiDomain}.extraConfig = /*caddy*/ ''
      basicauth {
        {$LOKI_USERNAME} {$LOKI_PASSWORD}
      }
      reverse_proxy ${server.http_listen_address}:${toString server.http_listen_port}
    '';

    services.loki =
      let
        dataDir = config.services.loki.dataDir;
      in
      {
        enable = true;
        configuration = {
          # https://grafana.com/docs/loki/latest/configure/examples/configuration-examples/
          auth_enabled = false;
          server = {
            http_listen_address = "0.0.0.0";
            http_listen_port = 3100;
            grpc_listen_port = 9095;
          };

          common = {
            path_prefix = dataDir;
            replication_factor = 1;
            ring = {
              instance_addr = "127.0.0.1";
              kvstore.store = "inmemory";
            };
          };

          schema_config = {
            configs = [
              {
                from = "2024-08-29";
                store = "tsdb";
                object_store = "filesystem";
                schema = "v13";
                index = {
                  prefix = "index_";
                  period = "24h";
                };
              }
            ];
          };

          compactor = {
            working_directory = "${dataDir}/retention";
            retention_enabled = true;
            delete_request_store = "filesystem";
          };

          limits_config = {
            retention_period = "90d";
          };

          storage_config = {
            filesystem = {
              directory = "${dataDir}/chunks";
            };
          };
        };
      };
    # https://grafana.com/docs/grafana/latest/datasources/loki/
    services.grafana.provision.datasources.settings.datasources = [
      {
        name = "Loki";
        type = "loki";
        uid = "loki";
        access = "proxy";
        url = "http://${server.http_listen_address}:${toString server.http_listen_port}";
        basicAuth = false;
        jsonData = {
          timeout = 60;
          maxLines = 1000;
        };
      }
    ];
  };
}
