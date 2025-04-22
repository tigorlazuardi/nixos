{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.vscode;
in
{
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
        golang.go
        esbenp.prettier-vscode
        catppuccin.catppuccin-vsc
      ];
    };
  };
}
