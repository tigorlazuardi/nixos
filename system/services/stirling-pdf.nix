{ lib, config, ... }:
let
  cfg = config.profile.services.stirling-pdf;
  domain = "pdf.tigor.web.id";
in
{
  config = lib.mkIf cfg.enable {
    services.stirling-pdf.enable = true;
    services.stirling-pdf.environment = {
      SERVER_PORT = 40002;
      SERVER_ADDRESS = "127.0.0.1";
    };
    systemd.socketActivations.stirling-pdf = with config.services.stirling-pdf.environment; {
      host = SERVER_ADDRESS;
      port = SERVER_PORT;
      idleTimeout = "5m";
    };
    services.nginx.virtualHosts =
      let
        opts = with config.systemd.socketActivations.stirling-pdf; {
          proxyPass = "http://unix:${socketAddress}";
        };
      in
      {
        "${domain}" = {
          useACMEHost = "tigor.web.id";
          forceSSL = true;
          enableAuthelia = true;
          autheliaLocations = [ "/" ];
          locations."/" = opts;
        };
        "pdf.local".locations."/" = opts;
      };
  };
}
