{ config, lib, ... }:
let
  cfg = config.services.postgres;
in
{
  services.postgresql = {
    identMap = ''
      postgres root postgres
    '';
  };
}
