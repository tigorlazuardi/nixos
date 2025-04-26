{ config, lib, ... }:
let
  podman = config.profile.podman;
  sonarr = podman.servarr.sonarr;
  name = "sonarr";
  name-anime = "${name}-anime";
  ip = "10.88.2.3";
  ip-anime = "10.88.2.33";
  image = "lscr.io/linuxserver/sonarr:latest";
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/${name}";
  configVolumeAnime = "${root}/${name-anime}";
  mediaVolume = "${root}/data";
  domain = "${name}.tigor.web.id";
  domain-anime = "${name-anime}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  inherit (lib) mkIf;
in
{
  config = mkIf (podman.enable && sonarr.enable) {
    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${ip}:8989";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts.${domain-anime} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${ip-anime}:8990";
        proxyWebsockets = true;
      };
    };

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${configVolume} ${mediaVolume} ${configVolumeAnime}
      chown ${uid}:${gid} ${mediaVolume} ${configVolume} ${configVolumeAnime}
    '';

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      environment = {
        PUID = uid;
        PGID = gid;
        TZ = "Asia/Jakarta";
      };
      volumes = [
        "${configVolume}:/config"
        "${mediaVolume}:/data"
      ];
      extraOptions = [
        "--ip=${ip}"
        "--network=podman"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };

    virtualisation.oci-containers.containers.${name-anime} = {
      inherit image;
      hostname = name-anime;
      autoStart = true;
      environment = {
        PUID = uid;
        PGID = gid;
        TZ = "Asia/Jakarta";
      };
      volumes = [
        "${configVolumeAnime}:/config"
        "${mediaVolume}:/data"
      ];
      extraOptions = [
        "--ip=${ip-anime}"
        "--network=podman"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
  };
}
