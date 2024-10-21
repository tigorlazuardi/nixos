{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.printing;
  username = config.profile.user.name;
in
{
  config = lib.mkIf cfg.enable {
    users.users.${username}.extraGroups = [ "lp" ];
    services.printing = {
      enable = true;
      drivers = [ pkgs.brlaser ]; # Brother Laser Printer
    };
  };
}
