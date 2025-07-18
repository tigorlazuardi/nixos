{
  config,
  lib,
  pkgs,
  ...
}:
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
      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
      };
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
  # 10.88.0.2 -> Redmage
  # 10.88.0.3 -> Redmage Demo
  # 10.88.0.4 -> ytptube
  # 10.88.1.1 -> Pihole
  imports = [
    ./cctv-ivms4200.nix
    ./jdownloader.nix
    ./memos.nix
    ./minecraft.nix
    ./morphos.nix
    ./openobserve.nix
    ./pihole.nix
    ./qbittorrent.nix
    ./redmage-demo.nix
    ./redmage.nix
    ./servarr
    ./soulseek.nix
    ./ytptube.nix
    ./valheim.nix

    ./penpot.nix
    ./metrics.nix
    ./n8n.nix
  ];
}
