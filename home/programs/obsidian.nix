{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.home.programs.obsidian;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable { home.packages = with pkgs; [ obsidian ]; };
}
