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


    systemd.tmpfiles.settings = {
      "promtail-dir" = {
        "/var/lib/promtail" = {
          d = {
            group = "promtail";
            mode = "0755";
            user = "promtail";
          };
        };
      };
    };

    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 3031;
          grpc_listen_port = 0;
        };
        clients = [
          {
            url = "http://${server.http_listen_address}:${toString server.http_listen_port}/loki/api/v1/push";
          }
        ];
        positions = {
          filename = "/var/lib/promtail/positions.yaml";
        };
        scrape_configs = [
          {
            job_name = "systemd-journal";
            relabel_configs = [
              {
                source_labels = [ "__journal__hostname" ];
                target_label = "host";
              }
              {
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "systemd_unit";
                regex = ''(.+)'';
              }
              {
                source_labels = [ "__journal__systemd_user_unit" ];
                target_label = "systemd_user_unit";
                regex = ''(.+)'';
              }
              {
                source_labels = [ "__journal__transport" ];
                target_label = "transport";
                regex = ''(.+)'';
              }
              {
                source_labels = [ "__journal_priority_keyword" ];
                target_label = "severity";
                regex = ''(.+)'';
              }
            ];
            journal = {
              labels = {
                job = "systemd-journal";
              };
              path = "/var/log/journal";
            };
          }
        ];
      };
    };

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
