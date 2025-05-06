{
  pkgs,
  lib,
  ...
}:
{
  programs.zsh.plugins = lib.mkOrder 100 [
    {
      name = "zsh-powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }
  ];
  programs.zsh.initContent = lib.mkOrder 2000 ''
    source ${./p10k.zsh}
  '';
}
