{ config, profile-path, ... }:
let
  user = config.profile.user;
  stateVersion = config.profile.system.stateVersion;
in
{
  imports = [
    profile-path

    ./programs
    ./modules

    ./config/wezterm
    ./config/nvim
    ./direnv.nix
    ./config/kitty
    ./config/ideavim
    ./secrets.nix
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = stateVersion;
  };
  programs.home-manager.enable = true;
  systemd.user.sessionVariables = {
    XDG_CONFIG_HOME = "/home/${user.name}/.config";
  };

  services.mpris-proxy.enable = config.profile.mpris-proxy.enable;
}
