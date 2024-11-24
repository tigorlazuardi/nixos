{ config, lib, ... }:
let
  podman = config.profile.podman;
  name = "radarr";
  radarr = podman.servarr.${name};
  ip = "10.88.2.7";
  image = "lscr.io/linuxserver/${name}:latest";
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/${name}";
  mediaVolume = "${root}/data";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  inherit (lib) mkIf;
in
{
  config = mkIf (podman.enable && radarr.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${ip}:7878
    '';

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${ip}:7878";
        proxyWebsockets = true;
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [ domain ];

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${configVolume} ${mediaVolume}
      chown ${uid}:${gid} ${mediaVolume} ${configVolume}
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
  };
}
