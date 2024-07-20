{ ... }:
{
  imports = [
    ../options
  ];

  profile = {
    hostname = "homeserver";
    networking.externalInterface = "enp9s0";
    networking.disableWaitOnline = true;
    user = {
      name = "homeserver";
      fullName = "Homeserver";
      getty.autoLogin = true;
    };
    system.stateVersion = "24.05";

    grub.enable = false;
    # There is no GUI on the server. No need for audio.
    audio.enable = false;
    security.sudo.wheelNeedsPassword = false;

    openssh.enable = true;
    go.enable = true;
    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    podman = {
      enable = true;
      pihole.enable = true;
      suwayomi.enable = true;
      ytptube.enable = true;
      redmage.enable = true;
      redmage-demo.enable = true;
      qbittorrent.enable = true;
      servarr.enable = true;
      servarr.recyclarr.enable = true;
      servarr.real-debrid-manager.enable = false;
      servarr.rdtclient.enable = true;
      openobserve.enable = true;
      minecraft.enable = true;
    };

    docker = {
      enable = false;
    };

    services = {
      caddy.enable = true;
      cockpit.enable = true;
      forgejo.enable = true;
      kavita.enable = true;
      samba.enable = true;
      nextcloud.enable = true;
      syncthing.enable = true;
      openvpn.enable = false;
      stubby.enable = true;
      jellyfin.enable = true;
      rust-motd.enable = true;
      wireguard.enable = true;
      photoprism.enable = true;
    };
  };
}
