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

    ../nixvim
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

  # This allows user rootless podman to use network's host by default.
  home.file.".config/containers/containers.conf".source =
    (pkgs.formats.toml { }).generate "containers.conf"
      {
        containers = {
          netns = "host";
        };
      };

  services.mpris-proxy.enable = config.profile.mpris-proxy.enable;

  sops.secrets =
    let
      sopsFile = ../secrets/ssh.yaml;
    in
    {
      "ai/gemini/api_key".sopsFile = ../secrets/ai.yaml;
      "ai/anthropic/api_key".sopsFile = ../secrets/ai.yaml;
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

  systemd.user.sessionVariables = {
    XDG_CONFIG_HOME = "/home/${user.name}/.config";
    NIXPKGS_ALLOW_UNFREE = "1";
    GEMINI_API_KEY_FILE = config.sops.secrets."ai/gemini/api_key".path;
    ANTHROPIC_API_KEY_FILE = config.sops.secrets."ai/anthropic/api_key".path;
  };
}
