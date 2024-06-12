{ config, lib, ... }:
let
  cfg = config.profile.docker;
in
{
  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.docker.autoPrune.enable = true;
    virtualisation.oci-containers.backend = "docker";
  };

  imports = [
    ./caddy.nix
    ./kavita.nix
  ];
}
