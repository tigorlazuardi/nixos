{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.telemetry.prometheus;
  inherit (lib) mkIf;
  procConfig = (pkgs.formats.yaml { }).generate "config.yml" {
    process_names = [
      {
        name = "{{.Username}} | {{.Comm}} | {{.Matches.Cmdline}}";
        cmdline = [ "(?P<Cmdline>.+)" ];
      }
    ];
  };
  ip = "10.88.0.5";
in
{
  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      port = 0; # Random
      enableAgentMode = true;
      globalConfig = {
        external_labels = {
          instance = "homeserver";
        };
      };
      remoteWrite =
        let
          mimirServer = config.services.mimir.configuration.server;
        in
        [
          {
            url = "http://${mimirServer.http_listen_address}:${toString mimirServer.http_listen_port}/api/v1/push";
          }
        ];
      scrapeConfigs = [
        {
          job_name = "systemd";
          static_configs = [
            {
              labels = {
                job = "systemd";
              };
              targets =
                let
                  systemdExporter = config.services.prometheus.exporters.systemd;
                in
                [ "${systemdExporter.listenAddress}:${toString systemdExporter.port}" ];
            }
          ];
        }
      ];
      exporters = {
        systemd = {
          enable = true;
        };
      };
    };
    virtualisation.oci-containers.containers."process-exporter" = {
      image = "docker.io/ncabatoff/process-exporter:latest";
      autoStart = true;
      hostname = "process-exporter";
      volumes = [
        "/proc:/host/proc"
        "${procConfig}:/config.yml"
      ];
      extraOptions = [
        "--network=podman"
        "--ip=${ip}"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
      cmd = [
        "--procfs"
        "/host/proc"
        "-config.path"
        "/config.yml"
        "-web.listen-address"
        "0.0.0.0:9256"
      ];
    };

    environment.etc."alloy/config.alloy".text = # hocon
      ''
        prometheus.scrape "process_exporter" {
          targets = [{
            __address__ = "${ip}:9256",
          }]
          job_name = "process-exporter"

          forward_to  = [prometheus.remote_write.mimir.receiver]
        }
      '';
  };
}
