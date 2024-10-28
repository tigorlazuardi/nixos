{ config, pkgs, ... }:
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
      allowedUDPPorts = [ 53 ];
    };

  services.resolved = {
    enable = true;
  };

  environment.etc."systemd/resolved.conf.d/10-bareksa.conf".source =
    (pkgs.formats.ini { }).generate "10-bareksa.conf"
      {
        Resolve = {
          # This dns server is only available when VPN is connected.
          DNS = "192.168.3.215";
          Domains = "~bareksa.local";
        };
      };
}
