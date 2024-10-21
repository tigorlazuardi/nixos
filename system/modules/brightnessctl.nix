{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.brightnessctl;
in
{
  config = lib.mkIf cfg.enable { environment.systemPackages = [ pkgs.brightnessctl ]; };
}
