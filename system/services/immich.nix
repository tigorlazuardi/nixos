{
  lib,
  config,
  ...
}:
let
  cfg = config.profile.services.immich;
  domain = "photos.tigor.web.id";
in
{
  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      mediaLocation = "/nas/services/immich";
      settings.server.externalDomain = "https://photos.tigor.web.id";
    };
    services.nginx.virtualHosts."${domain}" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" =
        let
          srv = config.services.immich;
        in
        {
          proxyPass = "http://${srv.host}:${toString srv.port}";
          proxyWebsockets = true;
        };
    };
  };
}
