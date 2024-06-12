{ config, lib, pkgs, ... }:
let
  cfg = config.profile.scanner;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      skanlite
    ];
    hardware.sane = {
      enable = true;
      brscan4.enable = true; # Brother Scanner
      extraBackends = with pkgs; [
        sane-airscan
      ];
    };
  };
}
