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
      host = "127.0.0.1";
      mediaLocation = "/wolf/services/immich";
      settings.server.externalDomain = "https://photos.tigor.web.id";
      accelerationDevices = [ "/dev/dri/renderD128" ];
    };
    systemd.socketActivations.immich-server =
      let
        inherit (config.services.immich) host port;
      in
      {
        inherit host port;
      };
    services.nginx.virtualHosts."${domain}" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations =
        let
          inherit (config.systemd.socketActivations.immich-server) socketAddress;
          inherit (config.services.anubis.instances.immich.settings) BIND;
        in
        {
          "/api" = {
            proxyPass = "http://unix:${socketAddress}";
            proxyWebsockets = true;
            extraConfig = ''
              client_max_body_size 4G;
            '';
          };
          "/" = {
            proxyPass = "http://unix:${BIND}";
            proxyWebsockets = true;
            extraConfig = ''
              client_max_body_size 4G;
            '';
          };
        };
    };
    services.anubis.instances.immich.settings.TARGET =
      let
        inherit (config.systemd.socketActivations.immich-server) socketAddress;
      in
      "unix://${socketAddress}";
  };
}
