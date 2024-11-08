{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.home.programs.jetbrains.idea;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable { home.packages = with pkgs; [ jetbrains.idea-community-bin ]; };
}
