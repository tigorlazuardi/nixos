{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.home.programs.nemo;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nemo-with-extensions
    ];

    dconf.settings = {
      "org/cinnamon/desktop/applications/terminal".exec = "kitty";
    };
  };
}
