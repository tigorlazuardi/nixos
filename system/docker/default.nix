{ config, lib, ... }:
let
  cfg = config.profile.docker;
  username = config.profile.user.name;
in
{
  config = lib.mkIf cfg.enable {
    users.users.${username}.extraGroups = [ "docker" ];
    virtualisation.docker.enable = true;
    virtualisation.docker.autoPrune.enable = true;
    virtualisation.oci-containers.backend = "docker";
  };

  imports = [
    ./caddy.nix
    ./kavita.nix
  ];
}
