{ config, lib, ... }:
let
  podman = config.profile.podman;
  qbittorrent = podman.servarr.qbittorrent;
  name = "qbittorrent-servarr";
  ip = "10.88.2.2";
  image = "lscr.io/linuxserver/qbittorrent:latest";
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/qbittorrent";
  mediaVolume = "${root}/data/torrents";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  inherit (lib) mkIf;
in
{
  config = mkIf (podman.enable && qbittorrent.enable) {
    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${ip}:8080";
        proxyWebsockets = true;
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [ domain ];

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${configVolume} ${mediaVolume}
      chown ${uid}:${gid} ${mediaVolume} ${configVolume}
    '';
    services.adguardhome.settings.user_rules = [
      "192.168.100.5 ${domain}"
    ];

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      environment = {
        PUID = uid;
        PGID = gid;
        TZ = "Asia/Jakarta";
        WEBUI_PORT = "8080";
        TORRENTING_PORT = "6882";
      };
      volumes = [
        "${configVolume}:/config"
        "${mediaVolume}:/data/torrents"
      ];
      ports = [
        "6882:6882"
        "6882:6882/udp"
      ];
      extraOptions = [
        "--ip=${ip}"
        "--network=podman"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
  };
}
