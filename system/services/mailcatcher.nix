{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf (config.profile.services.mailcatcher.enable) {
    services.mailcatcher = {
      enable = true;
      smtp.port = 25; # Use common SMTP port so other services can send emails without specifying port.
    };
    services.nginx.virtualHosts =
      let
        inherit (config.services.mailcatcher.http) ip port;
      in
      {
        "mail.local".locations."/".proxyPass = "http://${ip}:${toString port}";
        "mail.tigor.web.id" = {
          useACMEHost = "tigor.web.id";
          forceSSL = true;
          enableAuthelia = true;
          autheliaLocations = [ "/" ];
          locations."/".proxyPass = "http://${ip}:${toString port}";
        };
      };
    # smtp.local can be used to send emails by other services via SMTP protocol.
    services.adguardhome.settings.user_rules = [
      "192.168.100.5 stmp.local"
    ];
  };
}
