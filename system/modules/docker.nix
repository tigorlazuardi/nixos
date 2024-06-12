{ config, lib, ... }:
let
  cfg = config.profile.docker;
in
{
  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
  };
}
