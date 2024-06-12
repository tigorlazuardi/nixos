{ pkgs, ... }:
let
  user = "tigor";
  fullName = "Tigor Hutasuhut";
in
{
  users.users.${user} = {
    isNormalUser = true;
    description = fullName;
    extraGroups = [ "networkmanager" "wheel" "docker" "adbusers" "scanner" "lp" ];
    shell = pkgs.zsh;
  };

  users.groups.work = {
    name = "work";
    gid = 5555;
    members = [ user ];
  };

  nix.settings.trusted-users = [ user ];
}
