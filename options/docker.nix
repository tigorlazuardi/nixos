{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.profile.docker = {
    enable = lib.mkEnableOption "docker";
    caddy.enable = mkEnableOption "caddy docker";
    kavita.enable = lib.mkEnableOption "kavita docker";
  };
}
