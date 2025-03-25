{ config, lib, ... }:
let
  cfg = config.profile.services.navidrome;
  user = config.profile.user;
  domain = "navidrome.tigor.web.id";
  extraDomain = "music.tigor.web.id";
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.nginx.virtualHosts =
      let
        opts = {
          useACMEHost = "tigor.web.id";
          forceSSL = true;
          locations = {
            "/" = {
              proxyPass = "http://0.0.0.0:${toString config.services.navidrome.settings.Port}";
              proxyWebsockets = true;
            };
          };
        };
      in
      {
        "${domain}" = opts;
        "${extraDomain}" = opts;
      };

    security.acme.certs."tigor.web.id".extraDomainNames = [
      domain
      extraDomain
    ];

    services.adguardhome.settings.user_rules = [
      "192.168.100.5 ${domain}"
      "192.168.100.5 ${extraDomain}"
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
