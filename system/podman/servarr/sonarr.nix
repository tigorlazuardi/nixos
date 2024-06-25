{ config, lib, ... }:
let
  podman = config.profile.podman;
  sonarr = podman.servarr.sonarr;
  name = "sonarr";
  ip = "10.88.2.3";
  image = "lscr.io/linuxserver/sonarr:latest";
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/sonarr";
  mediaVolume = "${root}/data";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  inherit (lib) mkIf;
in
{
  config = mkIf (podman.enable && sonarr.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${ip}:8989
    '';

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
