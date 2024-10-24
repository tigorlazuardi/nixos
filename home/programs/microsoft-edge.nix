{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.microsoft-edge;
in
{
  config = lib.mkIf cfg.enable { home.packages = [ pkgs.microsoft-edge ]; };
}
