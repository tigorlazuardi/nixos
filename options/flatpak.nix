{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.profile.flatpak = {
    enable = mkEnableOption "flatpak";
    zen-browser.enable = mkEnableOption "zen-browser";
    redisinsight.enable = mkEnableOption "redisinsight";
  };
}
