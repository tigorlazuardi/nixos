{ config, lib, pkgs, ... }:
let
  cfg = config.profile.services.cockpit;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.profile.services.cockpit.enable = mkEnableOption "cockpit";
  config = mkIf cfg.enable {
    environment.systemPackages = mkIf config.profile.podman.enable [
      (pkgs.callPackage ../packages/cockpit-podman.nix { })
    ];
    sops.secrets."cockpit" = {
      sopsFile = ../../secrets/caddy_reverse_proxy.yaml;
      path = "/etc/caddy/sites-enabled/cockpit";
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
