{ config, lib, ... }:
let
  user = config.profile.user;
  docker = config.profile.docker;
  volume = "/nas/kavita";
  image = "lscr.io/linuxserver/kavita:latest";
  gid = toString user.gid;
  uid = toString user.uid;
in
{
  config = lib.mkIf (docker.enable && docker.kavita.enable) {
    system.activationScripts.docker-kavita = ''
      mkdir -p ${volume}
      chown -R ${user.name}:${gid} ${volume}
    '';

    virtualisation.oci-containers.containers.kavita = {
      inherit image;
      environment = {
        PUID = uid;
        PGID = gid;
        TZ = "Asia/Jakarta";
      };
      ports = [ "5000:5000" ];
      autoStart = true;
      volumes = [
        "${volume}/config:/config"
        "${volume}/library:/library"
      ];
    };
  };
}
