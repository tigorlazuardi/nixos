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
    services.caddy.virtualHosts."cockpit.tigor.web.id".extraConfig = # caddyfile
      ''
        @denied not remote_ip private_ranges

        respond @denied "Access denied" 403

        reverse_proxy 0.0.0.0:9090
      '';
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
