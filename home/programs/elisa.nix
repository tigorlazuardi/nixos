{ pkgs, config, lib, ... }:
let
  cfg = config.profile.home.programs.elisa;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kdePackages.elisa
    ];
  };
}
