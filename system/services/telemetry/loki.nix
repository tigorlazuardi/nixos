{ config, lib, ... }:
let
  cfg = config.profile.services.telemetry.loki;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.loki =
      let
        dataDir = config.services.loki.dataDir;
      in
      {
        enable = true;
        configuration = {
          # https://grafana.com/docs/loki/latest/configure/examples/configuration-examples/
          auth_enabled = false; # Loki will not be exposed to the public internet
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
        access = "proxy";
        url = "http://${config.services.loki.configuration.server.http_listen_address}:${toString config.services.loki.configuration.server.http_listen_port}";
        jsonData = {
          timeout = 60;
          maxLines = 1000;
        };
      }
    ];
  };
}
