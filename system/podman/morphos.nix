{ config, lib, ... }:
let
  name = "morphos";
  podman = config.profile.podman;
  inherit (lib) mkIf;
  ip = "10.88.88.2";
  image = "ghcr.io/danvergara/morphos-server:latest";
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
      locations."/" = {
        proxyPass = "http://unix:${config.services.anubis.instances.${name}.settings.BIND}";
        extraConfig = # nginx
          ''
            client_max_body_size 100M;
          '';
      };
    };

    services.anubis.instances.${name}.settings.TARGET = "http://${ip}:8080";

    virtualisation.oci-containers.containers.${name} = {
      inherit image;
      hostname = name;
      autoStart = true;
      user = "${uid}:${gid}";
      environment = {
        TZ = "Asia/Jakarta";
      };
      volumes = [ "/tmp:/tmp" ];
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
