{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.profile.spotify;
in
{
  config = lib.mkIf cfg.enable { home.packages = with pkgs; [ spotify ]; };
}
