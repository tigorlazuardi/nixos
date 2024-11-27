{
  config,
  pkgs,
  lib,
  ...
}:
{
  networking.networkmanager = {
    enable = true;
    appendNameservers = [ ] ++ lib.lists.optional config.services.adguardhome.enable "192.168.100.5";
  };
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
