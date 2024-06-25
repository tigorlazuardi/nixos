{ config, lib, ... }:
let
  podman = config.profile.podman;
  cfg = podman.servarr.real-debrid-manager;
  name = "real-debrid-manager";
  ip = "10.88.2.1";
  image = "docker.io/hyperbunny77/realdebridmanager:latest";
  volume = "/nas/mediaserver/servarr/real-debrid-manager";
  domain = "rdm.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  inherit (lib) mkIf;
in
{
  config = mkIf (podman.enable && cfg.enable) {
    services.caddy.${domain}.extraConfig = ''
      reverse_proxy ${ip}:5000
    '';

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${volume}/{config,downloads,watch}
      chown -R ${uid}:${gid} ${volume}/{config,downloads,watch}
    '';

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      user = "${uid}:${gid}";
      enviroment = {
        TZ = "Asia/Jakarta";
        rdmport = "5000";
      };
      volumes = [
        "${volume}/config:/config"
        "${volume}/downloads:/downloads"
        "${volume}/watch:/watch"
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
