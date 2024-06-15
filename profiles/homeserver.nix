{ ... }:
{
  imports = [
    ../options
  ];

  profile = {
    hostname = "homeserver";
    networking.externalInterface = "enp9s0";
    user = {
      name = "homeserver";
      fullName = "Homeserver";
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
      enable = false;
    };

    docker = {
      enable = true;
    };

    services = {
      caddy.enable = true;
      cockpit.enable = true;
      forgejo.enable = true;
      kavita.enable = true;
      samba.enable = true;
      nextcloud.enable = true;
      syncthing.enable = true;
      openvpn.enable = true;
      stubby.enable = true;
    };
  };
}
