{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.profile.home.programs.cursor;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      code-cursor
    ];
  };
}
