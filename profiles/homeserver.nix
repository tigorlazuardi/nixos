{ ... }:
{
  imports = [ ../options ];

  profile = {
    hostname = "homeserver";
    networking.externalInterface = "enp3s0";
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
      pihole.enable = false;
      ytptube.enable = true;
      redmage.enable = true;
      redmage-demo.enable = false;
      qbittorrent.enable = true;
      servarr.enable = true;
      servarr.recyclarr.enable = true;
      servarr.real-debrid-manager.enable = false;
      servarr.rdtclient.enable = true;
      openobserve.enable = false;
      minecraft.enable = false;
      memos.enable = true;
      morphos.enable = true;
      n8n.enable = false;
      soulseek.enable = true;
      valheim.enable = true;
      jdownloader.enable = true;
      cctv-ivms4200.enable = true;
    };

    home.programs.zellij = {
      enable = true;
      autoAttach = true;
      mod = "Ctrl b";
      zjstatus.theme = ../home/programs/zellij/themes/zjstatus/catppuccin-mocha.nix;
    };

    services = {
      adguardhome.enable = true;
      caddy.enable = false;
      immich.enable = true;
      nginx.enable = true;
      cockpit.enable = false;
      forgejo.enable = true;
      kavita.enable = true;
      samba.enable = true;
      nextcloud.enable = true;
      syncthing.enable = true;
      openvpn.enable = false;
      stubby.enable = false;
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
      suwayomi.enable = true;
      github-runner.enable = true;
      homepage-dashboard.enable = true;
      stirling-pdf.enable = true;
      mailcatcher.enable = true;
      db-gate.enable = true;
      penpot.enable = true;
    };
  };
}
