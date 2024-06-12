{ config, lib, ... }:
let
  cfg = config.profile.ideavim;
in
{
  config = lib.mkIf cfg.enable {
    home.file.".ideavimrc" = {
      source = ./.ideavimrc;
    };
  };
}
