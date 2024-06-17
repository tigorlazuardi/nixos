{ lib, ... }:
{
  options.profile.podman = {
    enable = lib.mkEnableOption "podman";
    caddy.enable = lib.mkEnableOption "caddy podman";
    kavita.enable = lib.mkEnableOption "kavita podman";
    pihole.enable = lib.mkEnableOption "pihole podman";
    suwayomi.enable = lib.mkEnableOption "suwayomi podman";
  };
}
