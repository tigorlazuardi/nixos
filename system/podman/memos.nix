{ config, lib, ... }:
let
  name = "memos";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  ip = "10.88.88.1";
  image = "docker.io/neosmemo/memos:stable";
  rootVolume = "/nas/podman/memos";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
in
{
  config = mkIf (podman.enable && podman.${name}.enable) {
    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/".proxyPass = "http://${ip}:5230";
    };

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${rootVolume}
      chown ${uid}:${gid} ${rootVolume}
    '';

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      user = "${uid}:${gid}";
      environment = {
        TZ = "Asia/Jakarta";
        # MEMOS_PUBLIC = "true";
      };
      volumes = [ "${rootVolume}:/var/opt/memos" ];
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
