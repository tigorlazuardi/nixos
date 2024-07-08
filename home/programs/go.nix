{ config, lib, ... }:
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
  };
}
