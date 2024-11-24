{ ... }:
{
  imports = [ ../options ];

  profile = {
    hostname = "homeserver";
    networking.externalInterface = "enp9s0";
    networking.disableWaitOnline = true;
    user = {
      name = "homeserver";
      fullName = "Homeserver";
      getty.autoLogin = false;
    };
    system.stateVersion = "24.05";

    grub.enable = false;
    # There is no GUI on the server. No need for audio.
    audio.enable = false;
    security.sudo.wheelNeedsPassword = false;

    openssh.enable = true;
    go.enable = true;
    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
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
      openobserve.enable = false;
      minecraft.enable = false;
      memos.enable = true;
      morphos.enable = true;
      soulseek.enable = true;
      valheim.enable = false;
    };

    home.programs.zellij = {
      enable = true;
      autoAttach = true;
      mod = "Ctrl b";
      zjstatus.theme = ../home/programs/zellij/themes/zjstatus/gruvbox-dark.nix;
    };

    services = {
      caddy.enable = false;
      nginx.enable = true;
      cockpit.enable = true;
      forgejo.enable = true;
      kavita.enable = true;
      samba.enable = true;
      nextcloud.enable = false;
      syncthing.enable = true;
      openvpn.enable = false;
      stubby.enable = true;
      jellyfin.enable = true;
      rust-motd.enable = true;
      wireguard.enable = true;
      photoprism.enable = false;
      navidrome.enable = true;
      telemetry.enable = true;
      ntfy-sh.enable = true;
      ntfy-sh.client.enable = false;
      couchdb.enable = false;
      technitium.enable = false;
    };
  };
}
