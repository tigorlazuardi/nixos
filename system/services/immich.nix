{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.immich;
  domain = "photos.tigor.web.id";
  socketAddress = "/run/immich.sock";
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
    systemd.services.immich-server = {
      unitConfig.StopWhenUnneeded = true;
      serviceConfig.ExecStartPost =
        let
          srv = config.services.immich;
        in
        "${pkgs.waitport}/bin/waitport ${srv.host} ${toString srv.port}";
    };
    systemd.sockets.immich-server-proxy = {
      listenStreams = [ socketAddress ];
      wantedBy = [ "sockets.target" ];
    };
    systemd.services.immich-server-proxy =
      let
        srv = config.services.immich;
      in
      {
        unitConfig = {
          Requires = [
            "immich-server.service"
            "immich-server-proxy.socket"
          ];
          After = [
            "immich-server.service"
            "immich-server-proxy.socket"
          ];
        };
        serviceConfig.ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=1h ${srv.host}:${toString srv.port}";
      };
    services.nginx.virtualHosts."${domain}" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      enableAuthelia = true;
      autheliaLocations = [ "/" ];
      locations =
        let
          opts = {
            proxyPass = "http://unix:${socketAddress}";
            proxyWebsockets = true;
            extraConfig = # nginx
              ''
                client_max_body_size 4G;
              '';
          };
        in
        {
          "/api" = opts;
          "/" = opts;
        };
    };
  };
}
