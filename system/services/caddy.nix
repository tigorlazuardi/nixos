{ config, lib, ... }:
let
  cfg = config.profile.services.caddy;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      extraConfig = ''
        import /etc/caddy/sites-enabled/*
      '';
    };

    sops.secrets."router" = {
      sopsFile = ../../secrets/caddy_reverse_proxy.yaml;
      path = "/etc/caddy/sites-enabled/router";
      mode = "0444";
    };
  };
}
