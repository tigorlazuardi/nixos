{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.scanner;
  username = config.profile.user.name;
in
{
  config = lib.mkIf cfg.enable {
    users.users.${username}.extraGroups = [ "scanner" ];
    environment.systemPackages = with pkgs; [ kdePackages.skanlite ];
    hardware.sane = {
      enable = true;
      brscan4.enable = true; # Brother Scanner
      extraBackends = with pkgs; [ sane-airscan ];
    };
  };
}
