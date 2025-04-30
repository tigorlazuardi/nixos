{
  pkgs,
  lib,
  ...
}:
{
  programs.zsh.plugins = lib.mkOrder 200 [
    {
      name = "zsh-f-sy-h";
      src = pkgs.zsh-f-sy-h;
      file = "share/zsh/site-functions/F-Sy-H.plugin.zsh";
    }
  ];
}
