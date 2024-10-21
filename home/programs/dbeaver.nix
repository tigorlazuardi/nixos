{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.dbeaver;
in
{
  config = lib.mkIf cfg.enable { home.packages = [ pkgs.dbeaver-bin ]; };
}
