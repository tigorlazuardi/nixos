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

    podman = {
      enable = true;
    };
    openssh.enable = true;
  };
}
