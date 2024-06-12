{ pkgs, unstable, ... }:
{
  imports = [
    ./bitwarden.nix
    ./chromium.nix
    ./discord.nix
    ./git.nix
    ./github.nix
    ./go.nix
    ./mpv.nix
    ./neovide.nix
    ./nnn.nix
    ./node.nix
    ./slack.nix
    ./spotify.nix
    ./starship.nix
    ./tofi.nix
    ./variety.nix
    ./vscode.nix
    ./whatsapp.nix
    ./zsh.nix
    ./dbeaver.nix
  ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f";
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
  programs.ripgrep.enable = true;
  programs.htop.enable = true;

  home.packages = with pkgs; [
    unstable.jellyfin-media-player
    unstable.microsoft-edge
    nextcloud-client
  ];
}
