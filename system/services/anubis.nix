{
  inputs,
  unstable,
  config,
  lib,
  ...
}:
let
  cfg = config.services.anubis;
  enabledInstances = lib.filterAttrs (_: conf: conf.enable) cfg.instances;
in
{
  # Anubis is a service to deny AI crawlers access servers by giving proof-of-work challenges.
  #
  # Basically making them do some work, delay them, and most of all cause cost increase if they
  # are stubborn enough to continue.
  imports = [
    # Until 25.05 is released, we need to use the unstable version.
    "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/anubis.nix"
  ];

  # The rest of the config will be defined elsewhere per service definitions, not here.
  # This file only holds the default options for the Anubis services.
  config = lib.mkIf (enabledInstances != { }) {
    services.anubis.package = unstable.anubis;
    services.anubis.defaultOptions = {
      settings = {
        SERVE_ROBOTS_TXT = true;
      };
    };
    # Allow nginx to read and write to the sockets created by Anubis.
    users.users.nginx.extraGroups = [ "anubis" ];
  };
}
