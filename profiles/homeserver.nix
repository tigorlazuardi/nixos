{ ... }:
{
  imports = [
    ../options
  ];

  profile = {
    hostname = "homeserver";
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
    cockpit.enable = true;
    docker = {
      enable = false;
      caddy.enable = false;
      kavita.enable = false;
    };
    podman = {
      enable = true;
      caddy.enable = false;
      kavita.enable = true;
    };

    services = {
      caddy.enable = true;
      cockpit.enable = true;
    };
  };
}
