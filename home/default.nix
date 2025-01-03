{
  config,
  profile-path,
  pkgs,
  ...
}:
let
  user = config.profile.user;
  stateVersion = config.profile.system.stateVersion;
in
{
  imports = [
    profile-path

    ./programs
    ./modules
    ./games
    ./environments

    ./direnv.nix
    ./secrets.nix
    ./ideavimrc.nix
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = stateVersion;
    packages = with pkgs; [ btop ];
  };
  programs.home-manager.enable = true;
  systemd.user.sessionVariables = {
    XDG_CONFIG_HOME = "/home/${user.name}/.config";
  };

  services.mpris-proxy.enable = config.profile.mpris-proxy.enable;

  sops.secrets =
    let
      sopsFile = ../secrets/ssh.yaml;
    in
    {
      "ssh/id_ed25519/public" = {
        inherit sopsFile;
        path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        mode = "0444";
      };
      "ssh/id_ed25519/private" = {
        inherit sopsFile;
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0400";
      };
      # "netrc" = {
      #   sopsFile = ../secrets/netrc.yaml;
      #   path = "${config.home.homeDirectory}/.netrc";
      #   mode = "0400";
      # };
    };
}
