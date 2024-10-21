{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.redis;
  inherit (lib) mkIf;
in
lib.mkMerge [ (mkIf cfg.client.cli.enable { home.packages = [ pkgs.redis ]; }) ]
