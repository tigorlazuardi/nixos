{ config, lib, unstable, ... }:
let
  cfg = config.profile.dbeaver;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ unstable.dbeaver-bin ];
  };
}
