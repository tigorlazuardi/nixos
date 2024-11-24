{ config, lib, ... }:
let
  podman = config.profile.podman;
  prowlarr = podman.servarr.prowlarr;
  name = "prowlarr";
  name-flaresolverr = "${name}-flaresolverr";
  ip = "10.88.2.4";
  ip-flaresolverr = "10.88.2.5";
  image = "lscr.io/linuxserver/prowlarr:latest";
  image-flaresolverr = "ghcr.io/flaresolverr/flaresolverr:latest";
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
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${ip}:9696
    '';

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${ip}:9696";
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [ domain ];

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${configVolume}
      chown ${uid}:${gid} ${configVolume}
    '';

    virtualisation.oci-containers.containers.${name-flaresolverr} = {
      image = image-flaresolverr;
      hostname = name-flaresolverr;
      autoStart = true;
      environment = {
        TZ = "Asia/Jakarta";
      };
      extraOptions = [
        "--ip=${ip-flaresolverr}"
        "--network=podman"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      environment = {
        PUID = uid;
        PGID = gid;
        TZ = "Asia/Jakarta";
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
