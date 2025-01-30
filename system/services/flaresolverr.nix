{ config, lib, ... }:
let
  cfg = config.profile.services.flaresolverr;
  inherit (lib) mkIf;
  ip = "10.88.100.100";
in
{
  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers."flaresolverr" = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      hostname = "flaresolverr";
      autoStart = true;
      environment = {
        TZ = "Asia/Jakarta";
      };
      extraOptions = [
        "--ip=${ip}"
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
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${ip}:8191";
        proxyWebsockets = true;
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [ cfg.domain ];
  };
}
