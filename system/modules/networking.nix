{ config, lib, ... }:
{
  networking.networkmanager.enable = true;
  networking.extraHosts = ''
    192.168.50.217 gitlab.bareksa.com
  '';
  networking.firewall =
    let
      cfg = config.profile.networking.firewall;
    in
    {
      enable = cfg.enable;
      allowedTCPPorts = cfg.allowedTCPPorts;
    };
}
