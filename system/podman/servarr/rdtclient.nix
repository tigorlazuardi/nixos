{ config, lib, ... }:
let
  podman = config.profile.podman;
  name = "rdtclient";
  cfg = podman.servarr.${name};
  ip = "10.88.2.1";
  image = "docker.io/rogerfar/rdtclient:latest";
  root = "/nas/mediaserver/servarr";
  volumeConfig = "${root}/${name}";
  mediaVolume = "${root}/data/torrents";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  inherit (lib) mkIf;
in
{
  config = mkIf (podman.enable && cfg.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${ip}:6500
    '';

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${ip}:6500";
        proxyWebsockets = true;
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [ domain ];

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${volumeConfig} ${mediaVolume}
      chown ${uid}:${gid} ${volumeConfig} ${mediaVolume}
    '';

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      # user = "${uid}:${gid}";
      environment = {
        TZ = "Asia/Jakarta";
        PUID = uid;
        PGID = gid;
      };
      volumes = [
        "${volumeConfig}:/data/db"
        "${mediaVolume}:/data/torrents"
      ];
      extraOptions = [
        "--network=podman"
        "--ip=${ip}"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
  };
}
