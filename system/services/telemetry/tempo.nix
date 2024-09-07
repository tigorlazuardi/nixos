{ config, lib, ... }:
let
  cfg = config.profile.services.telemetry.tempo;
  inherit (lib) mkIf;
  domain = "tempo.tigor.web.id";
  basic_auth = {
    username = "tempo/caddy/basic_auth/username";
    password = "tempo/caddy/basic_auth/password";
    template = "tempo/caddy/basic_auth";
  };
  server = config.services.tempo.settings.server;
in
{
  config = mkIf cfg.enable {
    sops = {
      secrets =
        let
          opts = { sopsFile = ../../../secrets/telemetry.yaml; owner = "grafana"; };
        in
        {
          ${basic_auth.username} = opts;
          ${basic_auth.password} = opts;
        };
      templates = {
        ${basic_auth.template}.content = /*sh*/ ''
          TEMPO_USERNAME=${config.sops.placeholder.${basic_auth.username}}
          TEMPO_PASSWORD=${config.sops.placeholder.${basic_auth.password}}
        '';
      };
    };

    systemd.services."caddy".serviceConfig = {
      EnvironmentFile = [ config.sops.templates.${basic_auth.template}.path ];
    };

    services.caddy.virtualHosts.${domain}.extraConfig = ''
      @require_auth not remote_ip private_ranges 

      basicauth @require_auth {
          {$TEMPO_USERNAME} {$TEMPO_PASSWORD}
      }

      reverse_proxy ${server.http_listen_address}:3200
    '';

    services.tempo = {
      enable = true;
      settings = {
        server = {
          http_listen_address = "0.0.0.0";
          http_listen_port = 3200;
          grpc_listen_port = 9096;
        };
        distributor = {
          receivers = {
            otlp = {
              protocols = {
                http = { };
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
            tags = [ "job" "instance" "pod" "namespace" ];
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
