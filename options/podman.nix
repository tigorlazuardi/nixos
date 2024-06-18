{ lib, ... }:
{
  options.profile.podman = {
    enable = lib.mkEnableOption "podman";
    caddy.enable = lib.mkEnableOption "caddy podman";
    pihole.enable = lib.mkEnableOption "pihole podman";
    suwayomi.enable = lib.mkEnableOption "suwayomi podman";
    ytptube.enable = lib.mkEnableOption "metube podman";
    redmage.enable = lib.mkEnableOption "redmage podman";
    redmage-demo.enable = lib.mkEnableOption "redmage-demo podman";
  };
}
