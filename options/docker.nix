{ lib, ... }:
{
  options.profile.docker = {
    enable = lib.mkEnableOption "docker";
    caddy.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    kavita.enable = lib.mkEnableOption "kavita docker";
  };
}
