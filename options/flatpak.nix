{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.profile.flatpak = {
    enable = mkEnableOption "flatpak";
    redisinsight.enable = mkEnableOption "redisinsight";
  };
}
