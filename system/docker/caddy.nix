{ config, lib, pkgs, ... }:
let
  user = config.profile.user;
  docker = config.profile.docker;
  cache = "/home/${user.name}/.cache/docker/caddy";
  image = "lucaslorentz/caddy-docker-proxy:ci-alpine";
in
{
  config = lib.mkIf (docker.enable && docker.caddy.enable) {
    system.activationScripts.docker-caddy = ''
      mkdir -p ${cache}
      chown -R ${config.profile.user.name} ${cache}
    '';
    systemd.services.create-caddy-network = with config.virtualisation.oci-containers; {
      serviceConfig = {
        Type = "oneshot";
        # ExecStop = "${pkgs.docker}/bin/docker network rm -f caddy";
      };
      wantedBy = [ "${backend}-caddy.service" ];
      script = ''${pkgs.docker}/bin/docker network inspect caddy || ${pkgs.docker}/bin/docker network create caddy'';
    };
    virtualisation.oci-containers.containers = {
      caddy = {
        inherit image;
        environment = {
          TZ = "Asia/Jakarta";
        };
        ports = [ "80:80" "443:443" ];
        autoStart = true;
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:z"
          "${cache}:/data"
        ];
        extraOptions = [
          "--network=caddy"
        ];
      };
    };
  };
}
