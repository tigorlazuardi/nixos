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
        "/" = {
          proxyPass = "http://0.0.0.0:${toString config.services.kavita.settings.Port}";
          proxyWebsockets = true;
        };
      };
    };

    services.adguardhome.settings.user_rules = [
      "192.168.100.5 ${domain}"
    ];

    security.acme.certs."tigor.web.id".extraDomainNames = [ domain ];
    services.kavita = {
      enable = true;
      tokenKeyFile = config.sops.secrets."kavita/token".path;
      settings = {
        Port = 40001;
      };
    };
  };
}
