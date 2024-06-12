{ config, lib, unstable, ... }:
let
  cfg = config.profile.vscode;
in
{
  config = lib.mkIf cfg.enable {
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
  };
}
