{ pkgs, config, lib, ... }:
let
  cfg = config.profile.home.programs.bruno;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bruno
    ];
  };
}
