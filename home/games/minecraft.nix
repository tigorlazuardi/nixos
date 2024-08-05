{ config, lib, pkgs, ... }:
let
  cfg = config.profile.games.minecraft;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      prismlauncher
    ];
  };
}
