{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.android;
  username = config.profile.user.name;
in
{
  config = lib.mkIf cfg.enable {
    users.users.${username}.extraGroups = [ "adbusers" ];
    programs.adb.enable = true;
    environment.systemPackages = with pkgs; [ androidenv.androidPkgs_9_0.platform-tools ];
  };
}
