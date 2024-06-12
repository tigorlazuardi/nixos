{ config, lib, pkgs, ... }:
let
  user = config.profile.user;
  podman = config.profile.podman;
  volume = "/nas/kavita";
  image = "lscr.io/linuxserver/kavita:latest";
  gid = toString user.gid;
  uid = toString user.uid;
  gateway = "10.1.1.1";
  subnet = "10.1.1.0/24";
  ip = "10.1.1.3";
  ip-range = "10.1.1.3/25";
in
{
  config = lib.mkIf (podman.enable && podman.kavita.enable) {
    services.caddy.virtualHosts."kavita.tigor.web.id".extraConfig = ''
      reverse_proxy ${ip}:5000
    '';

    systemd.services.create-kavita-network = with config.virtualisation.oci-containers; {
      serviceConfig.Type = "oneshot";
      wantedBy = [ "${backend}-kavita.service" ];
      script = ''${pkgs.podman}/bin/podman network exists kavita || ${pkgs.podman}/bin/podman network create --gateway=${gateway} --subnet=${subnet} --ip-range=${ip-range} kavita'';
    };

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
      extraOptions = [
        "--network=kavita"
        "--ip=${ip}"
      ];
      autoStart = true;
      volumes = [
        "${volume}/config:/config"
        "${volume}/library:/library"
      ];
    };
  };
}
