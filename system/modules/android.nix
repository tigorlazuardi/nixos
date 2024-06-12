{ config, lib, pkgs, ... }:
let
  cfg = config.profile.android;
in
{
  config = lib.mkIf cfg.enable {
    programs.adb.enable = true;
    environment.systemPackages = with pkgs; [
      androidenv.androidPkgs_9_0.platform-tools
    ];
  };
}
