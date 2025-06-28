{
  config,
  lib,
  ...
}:
let
  cfg = config.services.postgresql;
in
{
  config = lib.mkIf cfg.enable {
    services.postgresql = {
      identMap = ''
        postgres root postgres
      '';
    };
    virtualisation.oci-containers.containers.db-gate.volumes = [
      "/run/postgresql:/var/run/postgresql"
    ];
  };
}
