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
    packages = with pkgs; [
      btop
      (writeShellScriptBin "download_nixpkgs_cache_index" ''
        filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr A-Z a-z)"
        mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
        # -N will only download a new version if there is an update.
        wget -q -N https://github.com/nix-community/nix-index-database/releases/latest/download/$filename
        ln -f $filename files
      '')
    ];
  };
  programs.home-manager.enable = true;
  systemd.user.sessionVariables = {
    XDG_CONFIG_HOME = "/home/${user.name}/.config";
    NIXPKGS_ALLOW_UNFREE = "1";
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
    };
}
