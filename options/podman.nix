{ lib, ... }:
{
  options.profile.podman = {
    enable = lib.mkEnableOption "podman";
    caddy.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    kavita.enable = lib.mkEnableOption "kavita docker";
  };
}
