{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.cockpit;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = mkIf config.profile.podman.enable [
      (pkgs.callPackage ../packages/cockpit-podman.nix { })
    ];

    services.nginx.virtualHosts."cockpit.tigor.web.id" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://0.0.0.0:9090";
        proxyWebsockets = true;
        extraConfig = ''
          if ($auth_ip != off) {
              return 403;
          }
        '';
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [ "cockpit.tigor.web.id" ];

    services.adguardhome.settings.user_rules = [ "192.168.100.5 cockpit.tigor.web.id" ];

    services.udisks2.enable = true;
    services.cockpit = {
      enable = true;
      openFirewall = true;
      settings = {
        WebService = {
          AllowUnencrypted = true;
          ProtocolHeader = "X-Forwarded-Proto";
          ForwardedForHeader = "X-Forwarded-For";
        };
        Session = {
          IdleTimeout = 120; # 2 hours.
        };
      };
    };
  };
}
