{
  config,
  lib,
  ...
}:
let
  cfg = config.profile.services.telemetry.alloy;
  webguiListenAddress = "127.0.0.1:5319";
  otelcolHTTPListenAddress = "192.168.100.5:4318";
  otelcolGRPCListenAddress = "192.168.100.5:4317";
in
{
  config = lib.mkIf cfg.enable {
    services.alloy = {
      enable = true;
      extraFlags = [ ''--server.http.listen-addr=${webguiListenAddress}'' ];
    };

    services.nginx.virtualHosts."alloy.tigor.web.id" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      enableAuthelia = true;
      autheliaLocations = [ "/" ];
      locations."/".proxyPass = "http://${webguiListenAddress}";
    };

    services.nginx.virtualHosts."alloy.local".locations."/".proxyPass = "http://${webguiListenAddress}";

    systemd.services.alloy.serviceConfig = {
      User = "root";
    };

    environment.etc."alloy/config.alloy".text =
      let
        lokiConfig = config.services.loki.configuration;
        tempoProtocols = config.services.tempo.settings.distributor.receivers.otlp.protocols;
        mimirServer = config.services.mimir.configuration.server;
      in
      # hocon
      ''
        livedebugging {
          enabled = true
        }

        otelcol.receiver.otlp "homeserver" {
            grpc {
                endpoint = "${otelcolGRPCListenAddress}"
            }

            http {
                endpoint = "${otelcolHTTPListenAddress}"
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
            forward_to = [loki.process.general_json_pipeline.receiver]
            relabel_rules = loki.relabel.journal.rules
            labels = {
                job = "systemd-journal",
                component = "loki.source.journal",
            }
        }

        loki.process "general_json_pipeline" {
            forward_to = [loki.write.default.receiver]

            stage.json {
                expressions = {
                    level = "level",
                }
            }

            stage.labels {
                values = {
                    level = "",
                }
            }
        }

        otelcol.exporter.otlp "tempo" {
            client {
                endpoint = "${tempoProtocols.grpc.endpoint}"
                tls {
                      insecure = true
                      insecure_skip_verify = true
                }
            }
        }

        prometheus.exporter.unix "system" {}

        prometheus.scrape "system" {
            targets     = prometheus.exporter.unix.system.targets
            forward_to  = [prometheus.remote_write.mimir.receiver]
        }

        prometheus.exporter.self "alloy" {}

        prometheus.scrape "alloy" {
            targets     = prometheus.exporter.self.alloy.targets
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
