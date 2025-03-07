{ lib, ... }:
let
  types = lib.types;
  inherit (lib) mkOption;
in
{
  options.profile.hardware = {
    monitors = {
      primary = mkOption {
        type = types.str;
        default = "DP-1";
        description = "Primary monitor";
      };
    };
  };
}
