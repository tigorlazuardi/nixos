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

    systemd.timers."podman-auto-update" = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
    };
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
  # 10.1.1.0-3 -> Pihole
  # 10.1.1.4-7 -> ytptube
  # 10.1.1.8-11 -> Suwayomi
  # 10.1.1.12-15 -> Suwayomi
  # 10.1.1.16-19 -> Redmage
  # 10.1.1.20-23 -> Redmage Demo
  imports = [
    ./caddy.nix
    ./pihole.nix
    ./suwayomi.nix
    ./ytptube.nix
    ./redmage.nix
    ./redmage-demo.nix
  ];
}
