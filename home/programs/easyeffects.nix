{ config, lib, pkgs, ... }:
let
  cfg = config.profile.programs.easyeffects;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ easyeffects ];
  };
}
