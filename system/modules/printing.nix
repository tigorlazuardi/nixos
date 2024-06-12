{ config, lib, pkgs, ... }:
let
  cfg = config.profile.printing;
in
{
  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = [ pkgs.brlaser ]; # Brother Laser Printer
    };
  };
} 
