{ config, lib, ... }:
{
  config = lib.mkIf config.profile.environment.bareksa.enable {
    services.nginx.enable = true;

    # Disable ACME re-triggers every time the configuration changes
    systemd.services.nginx.unitConfig = {
      Before = lib.mkForce [ ];
      After = lib.mkForce [ "network.target" ];
      Wants = lib.mkForce [ ];
    };
  };
}
