{ config, lib, pkgs, ... }:
let
  cfg = config.profile.podman;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dive # look into docker image layers
      podman-tui # status of containers in the terminal
      podman-compose # start group of containers for dev
    ];

    virtualisation.podman = {
      enable = true;
      dockerSocket.enable = true;
      autoPrune.enable = true; # Default weekly
      dockerCompat = true;
    };
  };
}
