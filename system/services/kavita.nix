{ config, lib, ... }:
let
  cfg = config.profile.services.kavita;
  user = config.profile.user;
  domain = "kavita.tigor.web.id";
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    fileSystems."/nas/kavita" = {
      device = "/var/lib/kavita";
      fsType = "none";
      options = [ "bind" ];
    };
    system.activationScripts.ensure-kativa-permission = ''
      chmod -R 0775 /nas/kavita
    '';
    users.groups.kavita.members = [ user.name ];
    users.groups.${user.name}.members = [ "kavita" ]; # Allow kavita to read users's files copied to /var/lib/kavita via NAS
    sops.secrets."kavita/token" = {
      owner = "kavita";
      sopsFile = ../../secrets/kavita.yaml;
    };

    services.nginx.virtualHosts."${domain}" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations = {
        # Bypass anubis for Kavita API endpoints
        "/api" = {
          proxyPass = "http://unix:${config.systemd.socketActivations.kavita.socketAddress}";
          proxyWebsockets = true;
        };
        "/" = {
          proxyPass = "http://unix:${config.services.anubis.instances.kavita.settings.BIND}";
          proxyWebsockets = true;
        };
      };
    };

    services.anubis.instances.kavita.settings.TARGET =
      "unix://${config.systemd.socketActivations.kavita.socketAddress}";

    systemd.socketActivations."kavita" = {
      host = "0.0.0.0";
      port = 40001;
    };

    services.kavita = {
      enable = true;
      tokenKeyFile = config.sops.secrets."kavita/token".path;
      settings = {
        Port = 40001;
      };
    };
  };
}
