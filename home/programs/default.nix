{ ... }:
{
  imports = [
    ./zsh

    ./aider.nix
    ./bitwarden.nix
    ./bloomrpc.nix
    ./bruno.nix
    ./chromium.nix
    ./cursor.nix
    ./dbeaver.nix
    ./discord.nix
    ./dolphin.nix
    ./easyeffects.nix
    ./elisa.nix
    ./foot.nix
    ./ghostty.nix
    ./git.nix
    ./github.nix
    ./go.nix
    ./java.nix
    ./jellyfin.nix
    ./jetbrains-idea.nix
    ./kitty.nix
    ./krita.nix
    ./microsoft-edge.nix
    ./mongodb-compass.nix
    ./mpv.nix
    ./nemo.nix
    ./neocal.nix
    ./neovide.nix
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
