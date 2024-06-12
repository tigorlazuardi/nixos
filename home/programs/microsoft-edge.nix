{ config, lib, unstable, ... }:
let
  cfg = config.profile.microsoft-edge;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ unstable.microsoft-edge ];
  };
}
