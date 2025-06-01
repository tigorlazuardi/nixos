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
        set -e
        units=$(systemctl list-units --output json | jq -r '.[] | select(.unit | startswith("anubis-")) | .unit')
        for unit in $units; do
          echo "Restarting $unit"
          systemctl restart "$unit"
        done
      '')
    ];

    services.anubis.defaultOptions =
      let
        defaultBotPolicy = with builtins; fromJSON (readFile "${inputs.anubis}/data/botPolicies.json");
        botPolicy = defaultBotPolicy // {
          bots = [
            {
              name = "punish-empty-user-agent";
              expression = ''userAgent == ""'';
              action = "CHALLENGE";
              challenge = {
                difficulty = 16;
                report_as = 4;
                algorithm = "slow";
              };
            }

          ] ++ defaultBotPolicy.bots;
        };
      in
      {
        inherit botPolicy;
        settings.POLICY_FNAME = (pkgs.formats.yaml { }).generate "botPolicy.yaml" botPolicy;
      };

  };
}
