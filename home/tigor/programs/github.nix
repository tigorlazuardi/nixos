{ config, lib, unstable, ... }:
let
  cfg = config.profile.gh;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ unstable.gh ];
  };
}
