{ lib, ... }:
let
  inherit (lib) mkEnableOption types;
in
{
  options.profile.games = {
    minecraft.enable = mkEnableOption "Minecraft";
  };
}
