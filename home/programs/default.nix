{ ... }:
{
  imports = [
    ./bitwarden.nix
    ./chromium.nix
    ./dbeaver.nix
    ./discord.nix
    ./easyeffects.nix
    ./git.nix
    ./github.nix
    ./go.nix
    ./jellyfin.nix
    ./microsoft-edge.nix
    ./mpv.nix
    ./neovide.nix
    ./neovim.nix
    ./nextcloud.nix
    ./nnn.nix
    ./node.nix
    ./slack.nix
    ./spotify.nix
    # ./starship.nix
    ./tofi.nix
    ./variety.nix
    ./vscode.nix
    ./whatsapp.nix
    ./zathura.nix
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
