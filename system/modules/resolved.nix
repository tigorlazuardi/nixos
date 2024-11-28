{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.profile.services.resolved;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.resolved = {
      enable = config.profile.services.resolved.enable;
    };

    environment.etc."systemd/resolved.conf.d/10-bareksa.conf".source =
      (pkgs.formats.ini { }).generate "10-bareksa.com"
        {
          Resolve = {
            DNS = "192.168.3.215";
            Domains = "~bareksa.local";
          };
        };
  };
}
