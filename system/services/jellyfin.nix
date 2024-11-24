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

    services.caddy.virtualHosts.${domain}.extraConfig = ''
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
    services.caddy.virtualHosts.${domain-jellyseerr} = mkIf cfg.jellyseerr.enable {
      extraConfig = ''
        reverse_proxy 0.0.0.0:5055
      '';
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
