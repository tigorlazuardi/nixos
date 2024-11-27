{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.jellyfin;
  dataDir = "/nas/mediaserver/jellyfin";
  domain = "jellyfin.tigor.web.id";
  domain-jellyseerr = "jellyseerr.tigor.web.id";
  inherit (lib) mkIf;
  username = config.profile.user.name;
in
{
  config = mkIf cfg.enable {
    users.users.${username}.extraGroups = [ "jellyfin" ];
    users.users.jellyfin.extraGroups = [ username ];
    system.activationScripts.jellyfin-prepare = ''
      mkdir -p ${dataDir}
      chmod -R 0777 /nas/mediaserver
    '';

    services.nginx.virtualHosts."${domain}" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations = {
        "= /metrics" = {
          proxyPass = "http://0.0.0.0:8096";
          extraConfig =
            #nginx
            ''
              if ($auth_ip != off) {
                  return 403;
              }
            '';
        };
        "/" = {
          proxyPass = "http://0.0.0.0:8096";
          proxyWebsockets = true;
        };
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [
      domain
      domain-jellyseerr
    ];

    services.nginx.virtualHosts."${domain-jellyseerr}" = mkIf cfg.jellyseerr.enable {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://0.0.0.0:5055";
        proxyWebsockets = true;
      };
    };
    services.jellyfin = {
      enable = true;
      package = pkgs.jellyfin2405;
      inherit dataDir;
    };

    services.jellyseerr = mkIf cfg.jellyseerr.enable { enable = true; };

    environment.etc."alloy/config.alloy".text = # hcl
      ''
        prometheus.scrape "jellyfin" {
          targets = [{__address__ = "0.0.0.0:8096"}]
          job_name = "jellyfin"
          forward_to = [prometheus.remote_write.mimir.receiver]
        }
      '';
  };
}
