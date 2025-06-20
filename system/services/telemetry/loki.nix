{ config, lib, ... }:
let
  cfg = config.profile.services.telemetry.loki;
  inherit (lib) mkIf;
  inherit (lib.lists) optional;
in
{
  config = mkIf cfg.enable {
    services.nginx.virtualHosts =
      let
        inherit (config.services.loki.configuration.server) http_listen_address http_listen_port;
      in
      {
        "loki.local".locations."/".proxyPass = "http://${http_listen_address}:${toString http_listen_port}";
      };
    services.loki =
      let
        inherit (config.services.loki) dataDir;
      in
      {
        enable = true;
        configuration = {
          # https://grafana.com/docs/loki/latest/configure/examples/configuration-examples/
          auth_enabled = false;
          server = {
            http_listen_address = "127.0.0.1";
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
            retention_period = "30d";
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
        url = "http://loki.local";
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
