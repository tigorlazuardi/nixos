{ config, lib, pkgs, ... }:
let
  cfg = config.profile.nextcloud;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nextcloud-client ];
  };
}
