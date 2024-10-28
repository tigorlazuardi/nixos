{ config, lib, ... }:
let
  cfg = config.profile.services.technitium;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.technitium-dns-server = {
      enable = true;
      openFirewall = true;
    };

    services.caddy.virtualHosts."dns.tigor.web.id".extraConfig = ''
      @require_auth not remote_ip private_ranges 

      basic_auth @require_auth {
        {$AUTH_USERNAME} {$AUTH_PASSWORD}
      }

      reverse_proxy localhost:5380
    '';
  };
}
