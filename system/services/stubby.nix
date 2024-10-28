{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.stubby;
  inherit (lib) mkIf lists;
in
{
  config = mkIf cfg.enable {
    networking.resolvconf.useLocalResolver = false;
    networking.nameservers = lists.optional (!config.profile.podman.pihole.enable) "192.168.100.5";
    services.stubby = {
      enable = true;
      settings = pkgs.stubby.passthru.settingsExample // {
        listen_addresses = [ "192.168.100.3" ];
        upstream_recursive_servers = [
          {
            address_data = "1.1.1.1";
            tls_auth_name = "cloudflare-dns.com";
          }
          {
            address_data = "1.0.0.1";
            tls_auth_name = "cloudflare-dns.com";
          }
        ];
      };
    };
  };
}
