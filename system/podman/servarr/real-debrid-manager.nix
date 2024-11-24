{ config, lib, ... }:
let
  podman = config.profile.podman;
  name = "real-debrid-manager";
  real-debrid-manager = podman.servarr.${name};
  ip = "10.88.2.99";
  image = "docker.io/hyperbunny77/realdebridmanager:2022.06.27";
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/real-debrid-manager";
  mediaVolume = "${root}/data/torrents";
  watchVolume = "${mediaVolume}/watch";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  inherit (lib) mkIf;
in
{
  config = mkIf (podman.enable && real-debrid-manager.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${ip}:5000
    '';

    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${ip}:5000";
        proxyWebsockets = true;
      };
    };

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${configVolume} ${mediaVolume} ${watchVolume}
      chown ${uid}:${gid} ${configVolume} ${mediaVolume} ${watchVolume}
    '';

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      user = "${uid}:${gid}";
      environment = {
        TZ = "Asia/Jakarta";
        rdmport = "5000";
      };
      volumes = [
        "${configVolume}:/config"
        "${mediaVolume}:/data/torrents"
        "${watchVolume}:/watch"
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
