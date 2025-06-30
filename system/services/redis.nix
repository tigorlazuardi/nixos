{
  config,
  lib,
  ...
}:
let
  inherit (lib) mapAttrsToList;
in
{
  # Mount all redis unix socket paths to the db-gate container.
  # virtualisation.oci-containers.containers.db-gate =
  #   lib.mkIf (config.virtualisation.oci-containers.containers.db-gate != null)
  #     {
  #       volumes = mapAttrsToList (
  #         _: server: "${server.unixSocket}:${server.unixSocket}"
  #       ) config.services.redis.servers;
  #     };
}
