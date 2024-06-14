{ config, lib, ... }:
let
  cfg = config.profile.services.syncthing;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.caddy.virtualHosts."syncthing.tigor.web.id".extraConfig = ''
      reverse_proxy 0.0.0.0:8384
    '';
    services.syncthing = {
      enable = true;
      settings = {
        options.urAccepted = 1; # Allow anonymous usage reporting.
      };
      overrideFolders = false;
      overrideDevices = false;
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:8384";
    };
  };
}
