{ unstable, ... }:

{
  programs.vscode = {
    enable = true;
    package = unstable.vscode;
    extensions = with unstable.vscode-extensions; [
      dracula-theme.theme-dracula
      golang.go
      esbenp.prettier-vscode
      catppuccin.catppuccin-vsc
    ];
  };
}
