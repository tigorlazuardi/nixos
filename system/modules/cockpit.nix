{ config, lib, pkgs, ... }:
let
  cfg = config.profile.cockpit;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.mkIf config.profile.podman.enable [
      (pkgs.callPackage ../packages/cockpit-podman.nix { })
    ];
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
