{ pkgs, unstable, ... }:
{
  imports = [
    ./bitwarden.nix
    ./chromium.nix
    ./dbeaver.nix
    ./discord.nix
    ./git.nix
    ./github.nix
    ./go.nix
    ./microsoft-edge.nix
    ./mpv.nix
    ./neovide.nix
    ./nextcloud.nix
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
}
