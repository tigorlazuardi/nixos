{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.home.programs.bloomrpc;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ bloomrpc ];
  };
}
