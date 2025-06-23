{
  config,
  lib,
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
          extraConfig =
            #nginx
            ''
              return 403;
            '';
        };
        "/" = {
          proxyPass = "http://0.0.0.0:8096";
          proxyWebsockets = true;
        };
      };
    };

    services.jellyfin = {
      enable = true;
      inherit dataDir;
      openFirewall = true;
    };

    services.nginx.virtualHosts."${domain-jellyseerr}" = mkIf cfg.jellyseerr.enable {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://unix:${config.services.anubis.instances.jellyseerr.settings.BIND}";
        proxyWebsockets = true;
      };
    };
    services.anubis.instances.jellyseerr.settings.TARGET =
      "unix://${config.systemd.socketActivations.jellyseerr.socketAddress}";

    services.jellyseerr = mkIf cfg.jellyseerr.enable { enable = true; };
    systemd.socketActivations.jellyseerr = {
      host = "0.0.0.0";
      port = 5055;
    };

    environment.etc."alloy/config.alloy".text = # hocon
      ''
        prometheus.scrape "jellyfin" {
          targets = [{__address__ = "0.0.0.0:8096"}]
          job_name = "jellyfin"
          forward_to = [prometheus.remote_write.mimir.receiver]
        }
      '';
  };
}
