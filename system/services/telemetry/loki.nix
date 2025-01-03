{ config, lib, ... }:
let
  cfg = config.profile.services.telemetry.loki;
  inherit (lib) mkIf;
  inherit (lib.lists) optional;
  lokiDomain = "loki.tigor.web.id";
  server = config.services.loki.configuration.server;
in
{
  config = mkIf cfg.enable {
    services.caddy.virtualHosts.${lokiDomain}.extraConfig = # caddy
      ''
        basic_auth {
          {$AUTH_USERNAME} {$AUTH_PASSWORD}
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

          ruler = {
            external_url = "https://grafana.tigor.web.id";
            storage = {
              type = "local";
              local = {
                directory = "${dataDir}/rules";
              };
            };
            rule_path = "/tmp/loki/rules"; # Temporary rule_path
          };

          compactor = {
            working_directory = "${dataDir}/retention";
            retention_enabled = true;
            delete_request_store = "filesystem";
          };

          limits_config = {
            retention_period = "90d";
            ingestion_burst_size_mb = 64;
            ingestion_rate_mb = 32;
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
          derivedFields =
            [ ]
            ++ (optional config.services.tempo.enable {
              datasourceUid = "tempo";
              matcherRegex = ''trace_?[Ii][Dd]=(\w+)'';
              name = "Log Trace";
              url = "$\${__value.raw}";
              urlDisplayLabel = "Trace";
            })
            ++ (optional config.services.tempo.enable {
              datasourceUid = "tempo";
              matcherRegex = ''"trace_?[Ii][Dd]":"(\w+)"'';
              name = "Trace";
              url = "$\${__value.raw}";
              urlDisplayLabel = "Trace";
            });
        };
      }
    ];
  };
}
