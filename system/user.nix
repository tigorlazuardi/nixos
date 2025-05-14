{
  pkgs,
  config,
  lib,
  ...
}:
let
  user = config.profile.user.name;
  fullName = config.profile.user.fullName;
in
{
  users.users.${user} = {
    isNormalUser = true;
    description = fullName;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  users.groups.work = {
    name = "work";
    gid = 5555;
    members = [ user ];
  };

  nix.settings.trusted-users = [ user ];
  services.getty.autologinUser = lib.mkIf config.profile.user.getty.autoLogin user;
}
