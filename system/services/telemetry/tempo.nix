{ config, lib, ... }:
let
  cfg = config.profile.services.telemetry.tempo;
  inherit (lib) mkIf;
  domain = "tempo.tigor.web.id";
  server = config.services.tempo.settings.server;
in
{
  config = mkIf cfg.enable {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      @require_auth not remote_ip private_ranges 

      basic_auth @require_auth {
          {$AUTH_USERNAME} {$AUTH_PASSWORD}
      }

      reverse_proxy ${server.http_listen_address}:3200
    '';

    services.tempo = rec {
      enable = true;
      settings = {
        server = {
          http_listen_address = "192.168.100.3";
          http_listen_port = 3200;
          grpc_listen_port = 9096;
        };
        distributor = {
          receivers = {
            otlp = {
              protocols = {
                http = {
                  endpoint = "${settings.server.http_listen_address}:4318";
                };
                grpc = {
                  endpoint = "${settings.server.http_listen_address}:4317";
                };
              };
            };
          };
        };
        storage.trace = {
          backend = "local";
          local.path = "/var/lib/tempo/traces";
          wal.path = "/var/lib/tempo/wal";
        };
        ingester = {
          lifecycler.ring.replication_factor = 1;
        };
      };
    };
    services.grafana.provision.datasources.settings.datasources = [
      {
        name = "Tempo";
        type = "tempo";
        uid = "tempo";
        access = "proxy";
        url = "http://${server.http_listen_address}:${toString server.http_listen_port}";
        basicAuth = false;
        jsonData = {
          nodeGraph.enabled = true;
          search.hide = false;
          traceQuery = {
            timeShiftEnabled = true;
            spanStartTimeShift = "1h";
            spanEndTimeShift = "1h";
          };
          spanBar = {
            type = "Tag";
            tag = "http.path";
          };
          tracesToLogsV2 = mkIf config.profile.services.telemetry.loki.enable {
            datasourceUid = "loki";
            spanStartTimeShift = "-1h";
            spanEndTimeShift = "1h";
            tags = [
              "job"
              "instance"
              "pod"
              "namespace"
            ];
            filterByTraceID = false;
            filterBySpanID = false;
            customQuery = true;
            query = ''method="$''${__span.tags.method}"'';
          };
        };
      }
    ];
  };
}
