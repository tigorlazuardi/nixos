{ config, lib, pkgs, ... }:
let
  cfg = config.profile.services.cockpit;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = mkIf config.profile.podman.enable [
      (pkgs.callPackage ../packages/cockpit-podman.nix { })
    ];
    sops.secrets."cockpit" = {
      sopsFile = ../../secrets/caddy_reverse_proxy.yaml;
      path = "/etc/caddy/sites-enabled/cockpit";
      mode = "0440";
    };
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
