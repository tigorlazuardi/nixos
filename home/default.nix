{
  config,
  profile-path,
  pkgs,
  inputs,
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

    ./catppuccin.nix
    ./direnv.nix
    ./secrets.nix
    ./ideavimrc.nix

    inputs.sops-nix.homeManagerModules.sops
    inputs.nixvim.homeManagerModules.nixvim
    inputs.nix-index-database.hmModules.nix-index
    ../nixvim
    ../stylix
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
  programs.nix-index.enable = true;
  programs.home-manager.enable = true;

  # This allows user rootless podman to use network's host by default.
  home.file.".config/containers/containers.conf".source =
    (pkgs.formats.toml { }).generate "containers.conf"
      {
        containers = {
          netns = "host";
        };
      };

  services.mpris-proxy.enable = config.profile.mpris-proxy.enable;

  home.sessionVariables = {
    XDG_CONFIG_HOME = "/home/${user.name}/.config";
    NIXPKGS_ALLOW_UNFREE = "1";
  };
}
