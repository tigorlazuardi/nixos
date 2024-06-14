{ config, lib, pkgs, ... }:
let
  cfg = config.profile.services.stubby;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.stubby = {
      enable = true;
      settings = pkgs.stubby.passthru.settingsExample // {
        upstream_recursive_servers = [
          {
            address_data = "1.1.1.1";
            tls_auth_name = "cloudflare-dns.com";
          }
        ];
      };
    };
  };
}
