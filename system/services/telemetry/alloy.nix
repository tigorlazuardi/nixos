{ config, lib, inputs, unstable, ... }:
let
  cfg = config.profile.services.telemetry.alloy;
  webguiListenAddress = "0.0.0.0:5319";
  domain = "alloy.tigor.web.id";
  inherit (lib.strings) optionalString;
in
{
  imports = [
    # Grafana Alloy is still in unstable options.
    "${inputs.nixpkgs-unstable}/nixos/modules/services/monitoring/alloy.nix"
  ];

  config = lib.mkIf cfg.enable {
    services.alloy = {
      enable = true;
      extraFlags = [
        ''--server.http.listen-addr=${webguiListenAddress}''
      ];
      package = unstable.grafana-alloy;
    };


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
        "alloy-basic-auth".content = /*sh*/ ''
          ALLOY_USERNAME=${config.sops.placeholder."caddy/basic_auth/username"}
          ALLOY_PASSWORD=${config.sops.placeholder."caddy/basic_auth/password"}
        '';
      };
    };

    services.caddy.virtualHosts.${domain}.extraConfig = ''
      @require_auth not remote_ip private_ranges

      basicauth @require_auth {
        {$ALLOY_USERNAME} {$ALLOY_PASSWORD}
      }
    
      reverse_proxy ${webguiListenAddress}
    '';

    systemd.services.caddy.serviceConfig.EnvironmentFile = [
      config.sops.templates."alloy-basic-auth".path
    ];


    environment.etc."alloy/config.alloy".text =
      let
        lokiConfig = config.services.loki.configuration;
        tempoServer = config.services.tempo.settings.server;
        mimirServer = config.services.mimir.configuration.server;
      in
        /*hcl*/ ''
        otelcol.receiver.otlp "homeserver" {
            grpc {
                endpoint = "0.0.0.0:5317"
            }

            http {
                endpoint = "0.0.0.0:5318"
            }

            output {
                metrics = [otelcol.processor.batch.default.input]
                logs    = [otelcol.processor.batch.default.input]
                traces  = [otelcol.processor.batch.default.input]
            }
        }

        otelcol.processor.batch "default" {
            output {
                metrics = [otelcol.exporter.prometheus.mimir.input]
                logs    = [otelcol.exporter.loki.default.input]
                traces  = [otelcol.exporter.otlp.tempo.input]
            }
        }

        otelcol.exporter.loki "default" {
            forward_to = [loki.write.default.receiver]
        }

        otelcol.exporter.prometheus "mimir" {
            forward_to = [prometheus.remote_write.mimir.receiver]
        }

        loki.write "default" {
          endpoint {
            url = "http://${lokiConfig.server.http_listen_address}:${toString lokiConfig.server.http_listen_port}/loki/api/v1/push"
          }
        }

        loki.relabel "journal" {
            forward_to = []
            rule {
                source_labels = ["__journal__systemd_unit"]
                target_label  = "unit"
            }
            rule {
                source_labels = ["__journal__hostname"]
                target_label  = "host"
            }
            rule {
                source_labels = [ "__journal__systemd_user_unit" ]
                target_label = "user_unit"
            }
            rule {
                source_labels = [ "__journal__transport" ]
                target_label = "transport"
            }
            rule {
                source_labels = [ "__journal_priority_keyword" ]
                target_label = "severity"
            }
        }

        loki.source.journal "read" {
            forward_to = [loki.write.default.receiver]
            relabel_rules = loki.relabel.journal.rules
            labels = {
                job = "systemd-journal",
                component = "loki.source.journal",
            }
        }

        otelcol.exporter.otlp "tempo" {
            client {
                endpoint = "${tempoServer.http_listen_address}:${toString tempoServer.http_listen_port}"
            }
        }

        prometheus.exporter.unix "system" {}

        prometheus.scrape "system" {
            targets     = prometheus.exporter.unix.system.targets
            forward_to  = [prometheus.remote_write.mimir.receiver]
        }

        prometheus.remote_write "mimir" {
            endpoint {
                url = "http://${mimirServer.http_listen_address}:${toString mimirServer.http_listen_port}/api/v1/push"
            }
        }
      '';
  };
}
