{ lib, ... }:
{
  options.profile.podman = {
    enable = lib.mkEnableOption "podman";
  };
}
