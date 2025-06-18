{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.services.anubis;
  enabledInstances = lib.filterAttrs (_: conf: conf.enable) cfg.instances;
  hasInstances = (enabledInstances != { });
in
{
  config = {
    users.users.nginx.extraGroups = lib.mkIf hasInstances [
      config.users.groups.anubis.name
    ];

    environment.systemPackages = lib.mkIf hasInstances [
      (pkgs.writeShellScriptBin "restart-anubis" ''
        set -ex
        units=$(systemctl list-units --output json | ${pkgs.jq}/bin/jq -r '.[] | select(.unit | startswith("anubis-")) | .unit')
        systemctl restart $unit[@]
      '')
    ];
  };
}
