{ config, lib, ... }:
let
  cfg = config.profile.services.flaresolverr;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers."flaresolverr" = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      hostname = "flaresolverr";
      autoStart = true;
      environment = {
        TZ = "Asia/Jakarta";
        LOG_LEVEL = "debug";
      };
      extraOptions = [
        "--ip=${cfg.ip}"
        "--network=podman"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
      };
      ports = [
        "8191:8191"
      ];
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      locations."/" = {
        proxyPass = "http://${cfg.ip}:8191";
        proxyWebsockets = true;
      };
    };
  };
}
