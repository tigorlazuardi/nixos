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
      host = "0.0.0.0";
      mediaLocation = "/wolf/services/immich";
      settings.server.externalDomain = "https://photos.tigor.web.id";
      accelerationDevices = [ "/dev/dri/renderD128" ];
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
          extraConfig = # nginx
            ''
              client_max_body_size 4G;
            '';
        };
    };
  };
}
