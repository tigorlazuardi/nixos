{ config, lib, pkgs, ... }:
let
  user = config.profile.user;
  podman = config.profile.podman;
  cache = "/home/${user.name}/.cache/podman/caddy";
in
{
  config = lib.mkIf (podman.enable && podman.caddy.enable) {
    system.activationScripts.podman-caddy = ''
      mkdir -p ${cache}
      chown -R ${config.profile.user.name} ${cache}
    '';
    # https://fictionbecomesfact.com/caddy-container
    systemd.services.create-caddy-network = with config.virtualisation.oci-containers; {
      serviceConfig.Type = "oneshot";
      wantedBy = [ "${backend}-caddy.service" ];
      script = ''${pkgs.podman}/bin/podman network exists caddy || ${pkgs.podman}/bin/podman network create caddy'';
    };
    virtualisation.oci-containers.containers = {
      caddy = {
        image = "lucaslorentz/caddy-docker-proxy:ci-alpine";
        environment = {
          TZ = "Asia/Jakarta";
        };
        ports = [ "80:80" "443:443" ];
        autoStart = true;
        volumes = [
          "/run/user/${toString(user.uid)}/podman/podman.sock:/var/run/docker.sock:z"
          "${cache}:/data"
        ];
        extraOptions = [
          "--network=caddy"
        ];
      };
    };
  };
}
