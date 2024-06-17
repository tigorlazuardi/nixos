{ config, lib, pkgs, ... }:
let
  cfg = config.profile.podman;
  username = config.profile.user.name;
in
{
  config = lib.mkIf cfg.enable {
    users.users.${username}.extraGroups = [ "podman" ];
    # services.caddy.enable = true;
    environment.systemPackages = with pkgs; [
      dive # look into docker image layers
      podman-tui # status of containers in the terminal
    ];

    systemd.timers."podman-auto-update".enable = true;
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
    networking.firewall.interfaces."podman[0-9]+" = {
      allowedUDPPorts = [ 53 ]; # this needs to be there so that containers can look eachother's names up over DNS
    };
  };


  # Taken IP-Range Subnets
  #
  # 10.1.1.0-4 -> Pihole
  # 10.1.1.4-8 -> ytptube
  # 10.1.1.8-12 -> Suwayomi
  # 10.1.1.12-16 -> Suwayomi
  imports = [
    ./caddy.nix
    ./pihole.nix
    ./suwayomi.nix
    ./ytptube.nix
  ];
}
