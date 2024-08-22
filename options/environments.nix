{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.profile = {
    home.environments = {
      protobuf.enable = mkEnableOption "protobuf environments";
    };
  };
}
