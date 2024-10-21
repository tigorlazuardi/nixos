{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.gh;
in
{
  config = lib.mkIf cfg.enable { home.packages = [ pkgs.gh ]; };
}
