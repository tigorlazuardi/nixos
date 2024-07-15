{ config, lib, ... }:
let
  name = "openobserve";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  ip = "10.88.99.1";
  image = "public.ecr.aws/zinclabs/openobserve:latest";
  rootVolume = "/nas/podman/openobserve";
  domain = "${name}.tigor.web.id";
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
in
{
  config = mkIf (podman.enable && podman.${name}.enable) {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy ${ip}:5080
    '';

    system.activationScripts."podman-${name}" = ''
      mkdir -p ${rootVolume}/data
      chown ${uid}:${gid} ${rootVolume} ${rootVolume}/data
    '';

    sops.secrets."openobserve/env".sopsFile = ../../secrets/openobserve.yaml;

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      user = "${uid}:${gid}";
      environment = {
        TZ = "Asia/Jakarta";
        ZO_DATA_DIR = "/data";
        ZO_WEB_URL = "https://${domain}";
      };
      volumes = [
        "${rootVolume}/data:/data"
      ];
      extraOptions = [
        "--network=podman"
        "--ip=${ip}"
      ];
      environmentFiles = [
        config.sops.secrets."openobserve/env".path
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
  };

}
