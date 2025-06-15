{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.navidrome;
  user = config.profile.user;
  domain = "navidrome.tigor.web.id";
  extraDomain = "music.tigor.web.id";
  inherit (lib) mkIf;
  socketAddress = "/run/navidrome.sock";
in
{
  config = mkIf cfg.enable {
    services.nginx.virtualHosts =
      let
        opts = {
          useACMEHost = "tigor.web.id";
          forceSSL = true;
          locations = {
            "/api".proxyPass = "http://unix:${socketAddress}"; # bypass API endpoints from anubis
            "/rest".proxyPass = "http://unix:${socketAddress}"; # bypass REST API endpoints from anubis
            "/" = {
              proxyPass = "http://unix:${config.services.anubis.instances.navidrome.settings.BIND}";
              proxyWebsockets = true;
            };
          };
        };
      in
      {
        "${domain}" = opts;
        "${extraDomain}" = opts;
      };

    users.groups.navidrome.members = [ user.name ];
    users.groups.${user.name}.members = [ "navidrome" ];

    services.anubis.instances.navidrome.settings.TARGET = "unix://${socketAddress}";

    systemd.services.navidrome = {
      unitConfig.StopWhenUnneeded = true;
      serviceConfig.ExecStartPost =
        let
          settings = config.services.navidrome.settings;
        in
        [ "${pkgs.waitport}/bin/waitport ${settings.Address} ${toString settings.Port}" ];
      wantedBy = lib.mkForce [ ]; # This service will be started by systemd-socket-activation
    };

    systemd.sockets.navidrome-proxy = {
      listenStreams = [ socketAddress ];
      wantedBy = [ "sockets.target" ];
    };

    systemd.services.navidrome-proxy = {
      unitConfig = {
        Requires = [
          "navidrome.service"
          "navidrome-proxy.socket"
        ];
        After = [
          "navidrome.service"
          "navidrome-proxy.socket"
        ];
      };
      serviceConfig =
        let
          settings = config.services.navidrome.settings;
        in
        {
          ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5m ${settings.Address}:${toString settings.Port}";
        };
    };

    services.navidrome = {
      enable = true;
      settings = {
        Address = "127.0.0.1";
        MusicFolder = "/nas/Syncthing/Sync/Music";
      };
    };
  };
}
