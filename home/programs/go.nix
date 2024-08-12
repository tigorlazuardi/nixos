{ config, lib, pkgs, ... }:
let
  cfg = config.profile.go;
in
{
  config = lib.mkIf cfg.enable {
    programs.go = {
      enable = true;
      goPrivate = [
        "gitlab.bareksa.com"
      ];
    };
    home.packages = with pkgs; [
      gotools

      ###### Golang development tools ######
      gomodifytags
      gotests
      iferr
    ];
  };
}
