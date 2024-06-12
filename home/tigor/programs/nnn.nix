{ config, lib, ... }:
let
  cfg = config.profile.nnn;
in
{
  config = lib.mkIf cfg.enable {
    programs.nnn.enable = true;
  };
}
