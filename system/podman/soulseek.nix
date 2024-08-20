{ config, lib, ... }:
let
  name = "soulseek";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  ip = "10.88.60.80";
  image = "ghcr.io/fletchto99/nicotine-plus-docker:latest";
  rootVolume = "/nas/podman/soulseek";
  rootVolumeMusic = "/nas/Syncthing/Sync/Music";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
in
{
  config = mkIf (podman.enable && podman.${name}.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${ip}:6080
    '';

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${rootVolume}/{config,downloads,incomplete}
      chown ${uid}:${gid} ${rootVolume} ${rootVolume}/{config,downloads,incomplete}
    '';

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      environment = {
        TZ = "Asia/Jakarta";
        PUID = uid;
        PGID = gid;
      };
      volumes = [
        "${rootVolume}/config:/config"
        "${rootVolume}/incomplete:/data/incomplete_downloads"
        "${rootVolumeMusic}:/data/shared"
      ];
      ports = [
        "2234-2239:2234-2239"
      ];
      extraOptions = [
        "--network=podman"
        "--ip=${ip}"
        "--security-opt=seccomp=unconfined"
        "--device=/dev/dri:/dev/dri"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
  };

}
