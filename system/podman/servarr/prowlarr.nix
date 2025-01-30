{ config, lib, ... }:
let
  podman = config.profile.podman;
  prowlarr = podman.servarr.prowlarr;
  name = "prowlarr";
  ip = "10.88.2.4";
  image = "lscr.io/linuxserver/prowlarr:latest";
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/prowlarr";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  inherit (lib) mkIf;
in
{
  config = mkIf (podman.enable && prowlarr.enable) {
    profile.services.flaresolverr.enable = lib.mkForce true;
    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${ip}:9696";
        proxyWebsockets = true;
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [ domain ];

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${configVolume}
      chown ${uid}:${gid} ${configVolume}
    '';

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      environment = {
        PUID = uid;
        PGID = gid;
        TZ = "Asia/Jakarta";
        LOG_LEVEL = "debug";
        LOG_HTML = "true";
      };
      volumes = [ "${configVolume}:/config" ];
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
