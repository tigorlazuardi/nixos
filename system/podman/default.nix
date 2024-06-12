{ config, lib, pkgs, ... }:
let
  cfg = config.profile.podman;
in
{
  config = lib.mkIf cfg.enable {
    services.caddy.enable = true;
    environment.systemPackages = with pkgs; [
      dive # look into docker image layers
      podman-tui # status of containers in the terminal
      podman-compose # start group of containers for dev
    ];

    virtualisation.containers.enable = true;
    virtualisation.oci-containers.backend = "podman";
    virtualisation.podman = {
      enable = true;
      dockerSocket.enable = true;
      autoPrune.enable = true; # Default weekly
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    # https://madison-technologies.com/take-your-nixos-container-config-and-shove-it/
    networking.firewall.interfaces.podman1 = {
      allowedUDPPorts = [ 53 ]; # this needs to be there so that containers can look eachother's names up over DNS
    };
  };


  imports = [
    ./caddy.nix
    ./kavita.nix
  ];
}
