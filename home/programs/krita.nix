{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.home.programs.krita;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable { home.packages = with pkgs; [ krita ]; };
}
