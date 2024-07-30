{ config, lib, ... }:
{
  networking.networkmanager.enable = true;
  networking.extraHosts = ''
    192.168.50.217 gitlab.bareksa.com
    192.168.50.205 apicurio.prod.bareksa.local
    192.168.3.50 kafka.dev.bareksa.local
    192.168.3.109 redpanda.dev.bareksa.local kafka-console.dev.bareksa.local
  '';
  networking.firewall =
    let
      cfg = config.profile.networking.firewall;
    in
    {
      enable = cfg.enable;
      allowedTCPPorts = cfg.allowedTCPPorts;
      allowedUDPPorts = [ 53 ];
    };
}
