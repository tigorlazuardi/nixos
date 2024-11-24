{ config, lib, ... }:
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
          return = "403";
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

    services.caddy.virtualHosts."${domain}".extraConfig = ''
      @public not remote_ip private_ranges

      handle_path /metrics {
        header @public Content-Type text/html
        respond @public <<HTML
            <!DOCTYPE html>
            <html>
                <head>
                    <title>Access Denied</title>
                </head>
                <body>
                    <h1>Access Denied</h1>
                </body>
            </html>
            HTML 403
        reverse_proxy 0.0.0.0:8096
      }

      handle {
        reverse_proxy 0.0.0.0:8096
      }
    '';
    services.caddy.virtualHosts."${domain-jellyseerr}" = mkIf cfg.jellyseerr.enable {
      extraConfig = ''
        reverse_proxy 0.0.0.0:5055
      '';
    };

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
