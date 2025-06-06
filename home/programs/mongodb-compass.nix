{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.programs.mongodb-compass;
  sopsFile = ../../secrets/bareksa.yaml;
in
{
  config = lib.mkIf cfg.enable {
    sops.secrets."bareksa/mongodb-compass" = {
      inherit sopsFile;
    };
    home.packages = [ pkgs.mongodb-compass ];
  };
}
