{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.profile.wine;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wine64
      wineWowPackages.staging
      wineWowPackages.waylandFull
      winetricks
    ];
  };
}
