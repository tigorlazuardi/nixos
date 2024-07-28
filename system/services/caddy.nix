{ config, lib, ... }:
let
  cfg = config.profile.services.caddy;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
    };

    services.caddy.virtualHosts."router.tigor.web.id".extraConfig = ''
      @denied not remote_ip private_ranges 

      respond @denied "Access denied" 403

      reverse_proxy 192.168.100.1
    '';
  };
}
