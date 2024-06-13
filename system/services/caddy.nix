{ config, lib, ... }:
let
  cfg = config.profile.services.caddy;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.profile.services.caddy.enable = mkEnableOption "Caddy";

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      extraConfig = ''
        import /etc/caddy/sites-enabled/*
      '';
    };
  };
}
