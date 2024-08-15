{ config, lib, pkgs, ... }:
let
  cfg = config.profile.home.programs.zoom;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      zoom-us
    ];
  };
}
