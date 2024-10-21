{ config, lib, ... }:
let
  cfg = config.profile.services.telemetry.prometheus;
  inherit (lib) mkIf;
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
  };
}
