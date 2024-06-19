{ config, lib, ... }:
let
  cfg = config.profile.home.programs.zathura;
in
{
  config = lib.mkIf cfg.enable {
    programs.zathura = {
      enable = true;
    };
  };
}
