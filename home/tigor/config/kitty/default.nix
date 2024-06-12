{ config, lib, ... }:
let
  cfg = config.profile.kitty;
in
{
  config = lib.mkIf cfg.enable {
    programs.kitty.enable = true;

    home.file.".config/kitty" = {
      source = ./.;
      recursive = true;
    };
  };
}
