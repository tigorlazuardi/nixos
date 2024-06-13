{ config, lib, ... }:
let
  cfg = config.profile.services.forgejo;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    sops.secrets."forgejo" = {
      sopsFile = ../../secrets/caddy_reverse_proxy.yaml;
      path = "/etc/caddy/sites-enabled/forgejo";
      mode = "0440";
    };

    services.forgejo = {
      enable = true;
      settings = {
        server.PROTOCOL = "http+unix";
        session.COOKIE_SECURE = true;
      };
    };
  };
}
