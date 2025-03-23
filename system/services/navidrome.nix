{ config, lib, ... }:
let
  cfg = config.profile.services.navidrome;
  user = config.profile.user;
  domain = "navidrome.tigor.web.id";
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.nginx.virtualHosts."${domain}" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://0.0.0.0:${toString config.services.navidrome.settings.Port}";
          proxyWebsockets = true;
        };
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [ domain ];

    services.adguardhome.settings.user_rules = [
      "192.168.100.5 ${domain}"
    ];

    users.groups.navidrome.members = [ user.name ];
    users.groups.${user.name}.members = [ "navidrome" ];

    services.navidrome = {
      enable = true;
      settings = {
        Address = "0.0.0.0";
        MusicFolder = "/nas/Syncthing/Sync/Music";
      };
    };
  };
}
