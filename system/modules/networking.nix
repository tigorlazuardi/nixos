{ config, pkgs, ... }:
{
  networking.networkmanager.enable = true;
  networking.extraHosts = ''
    192.168.50.217 gitlab.bareksa.com
    192.168.50.205 apicurio.prod.bareksa.local
    192.168.3.50 kafka.dev.bareksa.local
    192.168.3.109 redpanda.dev.bareksa.local kafka-console.dev.bareksa.local
    192.168.50.102 kafka1.prod.bareksa.local
    192.168.50.103 kafka2.prod.bareksa.local
    192.168.50.104 kafka3.prod.bareksa.local
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
