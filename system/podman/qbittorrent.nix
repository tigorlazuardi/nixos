{ config, lib, ... }:
let
  name = "qbittorrent";
  domain = "${name}.tigor.web.id";
  podman = config.profile.podman;
  qbittorrent = podman.qbittorrent;
  inherit (lib) mkIf;
  ip = "10.88.0.7";
  image = "lscr.io/linuxserver/qbittorrent:latest";
  volume = "/nas/torrents";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
in
{
  config = mkIf (podman.enable && qbittorrent.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${ip}:8080
    '';

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${volume}/{config,downloads,progress,watch}
      chown ${uid}:${gid} ${volume} ${volume}/{config,downloads,progress,watch}
    '';

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      environment = {
        PUID = uid;
        PGID = gid;
        TZ = "Asia/Jakarta";
        WEBUI_PORT = "8080";
        TORRENTING_PORT = "6881";
      };
      volumes = [
        "${volume}/config:/config"
        "${volume}/downloads:/downloads"
        "${volume}/progress:/progress"
        "${volume}/watch:/watch"
      ];
      ports = [
        "6881:6881"
        "6881:6881/udp"
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

