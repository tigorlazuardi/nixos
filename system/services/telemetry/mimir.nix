{ config, lib, ... }:
let
  cfg = config.profile.services.telemetry.mimir;
  inherit (lib) mkIf;
  baseDir = "/var/lib/mimir";
  domain = "mimir.tigor.web.id";
in
{
  config = mkIf cfg.enable {
    sops = {
      secrets =
        let
          opts = { };
        in
        {
          "caddy/basic_auth/username" = opts;
          "caddy/basic_auth/password" = opts;
        };
      templates = {
        "mimir-basic-auth".content = /*sh*/ ''
          MIMIR_USERNAME=${config.sops.placeholder."caddy/basic_auth/username"}
          MIMIR_PASSWORD=${config.sops.placeholder."caddy/basic_auth/password"}
        '';
      };
    };

    systemd.services."caddy".serviceConfig = {
      EnvironmentFile = [ config.sops.templates."mimir-basic-auth".path ];
    };


    services.caddy.virtualHosts.${domain}.extraConfig =
      let
        mimirServerConfig = config.services.mimir.configuration.server;
        hostAddress = "${mimirServerConfig.http_listen_address}:${toString mimirServerConfig.http_listen_port}";
      in
      ''
        @require_auth not remote_ip private_ranges

        basicauth @require_auth {
          {$ALLOY_USERNAME} {$ALLOY_PASSWORD}
        }
    
        reverse_proxy ${hostAddress}
      '';

    services.mimir = {
      enable = true;
      configuration = {
        multitenancy_enabled = false;
        server = {
          http_listen_address = "0.0.0.0";
          http_listen_port = 4400;
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
        server = config.services.mimir.configuration.server;
      in
      [
        {
          name = "Mimir";
          type = "prometheus";
          uid = "mimir";
          access = "proxy";
          url = "http://${server.http_listen_address}:${toString server.http_listen_port}";
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
