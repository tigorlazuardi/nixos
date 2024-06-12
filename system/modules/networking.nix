{ config, ... }:
{
  networking.networkmanager.enable = true;
  networking.extraHosts = ''
    192.168.50.217 gitlab.bareksa.com
  '';
  networking.firewall.enable = config.profile.networking.firewall.enable;
}
