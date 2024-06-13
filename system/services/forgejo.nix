{ config, lib, ... }:
let
  cfg = config.profile.services.forgejo;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.caddy.virtualHosts."git.tigor.web.id".extraConfig = ''
      reverse_proxy * unix//run/forgejo/forgejo.sock
    '';


    services.forgejo = {
      enable = true;
      settings = {
        server = {
          PROTOCOL = "http+unix";
          SSH_PORT = 2222;
          DOMAIN = "git.tigor.web.id";
          HTTP_PORT = 443;
          ROOT_URL = "https://${config.services.forgejo.settings.server.DOMAIN}:${toString config.services.forgejo.settings.server.HTTP_PORT}";
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        session.COOKIE_SECURE = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ config.services.forgejo.settings.server.SSH_PORT ];
  };
}
