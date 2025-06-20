{ config, lib, ... }:
let
  cfg = config.profile.services.telemetry.mimir;
  inherit (lib) mkIf;
  baseDir = "/var/lib/private/mimir";
in
{
  config = mkIf cfg.enable {
    services.nginx.virtualHosts =
      let
        inherit (config.services.mimir.configuration.server) http_listen_address http_listen_port;
      in
      {
        "mimir.local".locations."/".proxyPass =
          "http://${http_listen_address}:${toString http_listen_port}";
      };

    services.mimir = {
      enable = true;
      configuration = {
        multitenancy_enabled = false;
        server = {
          http_listen_address = "127.0.0.1";
          http_listen_port = 9009;
          grpc_listen_port = 4401;
        };

        common = {
          storage = {
            backend = "filesystem";
            filesystem.dir = "${baseDir}/metrics";
          };
        };

        blocks_storage = {
          backend = "filesystem";
          bucket_store.sync_dir = "${baseDir}/tsdb-sync";
          filesystem.dir = "${baseDir}/data/tsdb";
          tsdb.dir = "${baseDir}/tsdb";
        };

        compactor = {
          data_dir = "${baseDir}/data/compactor";
          sharding_ring.kvstore.store = "memberlist";
        };

        limits = {
          compactor_blocks_retention_period = "30d";
          max_label_name_length = 1024;
          max_label_value_length = 2048;
        };

        distributor = {
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "memberlist";
          };
        };

        ingester = {
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "memberlist";
            replication_factor = 1;
          };
        };

        ruler_storage = {
          backend = "filesystem";
          filesystem.dir = "${baseDir}/data/rules";
        };

        store_gateway.sharding_ring.replication_factor = 1;
      };
    };

    services.grafana.provision.datasources.settings.datasources =
      let
        inherit (config.services.mimir.configuration.server) http_listen_address http_listen_port;
      in
      [
        {
          name = "Mimir";
          type = "prometheus";
          uid = "mimir";
          access = "proxy";
          url = "http://${http_listen_address}:${toString http_listen_port}/prometheus";
          basicAuth = false;
          jsonData = {
            httpMethod = "POST";
            prometheusType = "Mimir";
            timeout = 30;
          };
        }
      ];
  };
}
