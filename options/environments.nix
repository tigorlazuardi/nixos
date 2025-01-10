{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.profile = {
    environment = {
      bareksa.enable = mkEnableOption "bareksa environments";
    };
    home.environments = {
      protobuf.enable = mkEnableOption "protobuf environments";
    };
  };
}
