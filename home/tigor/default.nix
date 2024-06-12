{ pkgs, profile-path, ... }:
{
  imports = [
    profile-path

    ./programs
    ../modules

    ./config/wezterm
    ./config/nvim
    ./direnv.nix
    ./config/kitty
    ./config/ideavim
    ./secrets.nix
  ];

  home = {
    username = "tigor";
    homeDirectory = "/home/tigor";
    stateVersion = "23.11";
  };


  systemd.user.sessionVariables = {
    XDG_CONFIG_HOME = "/home/tigor/.config";
  };

  services.mpris-proxy.enable = true;
}
