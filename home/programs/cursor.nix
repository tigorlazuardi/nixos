{
  pkgs,
  config,
  lib,
  unstable,
  ...
}:
let
  cfg = config.profile.home.programs.cursor;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      unstable.code-cursor
      go
      gopls
      go-tools
      gotools
      impl
    ];
  };
}
