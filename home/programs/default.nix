{ ... }:
{
  imports = [
    ./bitwarden.nix
    ./bruno.nix
    ./chromium.nix
    ./dbeaver.nix
    ./discord.nix
    ./easyeffects.nix
    ./elisa.nix
    ./foot.nix
    ./git.nix
    ./github.nix
    ./go.nix
    ./java.nix
    ./jellyfin.nix
    ./jetbrains-idea.nix
    ./kitty.nix
    ./microsoft-edge.nix
    ./mongodb-compass.nix
    ./mpv.nix
    ./neovide.nix
    ./neovim.nix
    ./nextcloud.nix
    ./nnn.nix
    ./node.nix
    ./obsidian.nix
    ./redis.nix
    ./slack.nix
    ./spotify.nix
    ./starship.nix
    ./tofi.nix
    ./variety.nix
    ./vscode.nix
    ./whatsapp.nix
    ./yazi.nix
    ./zathura.nix
    ./zoom.nix
    ./zsh.nix

    ./wezterm
    ./zellij
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
