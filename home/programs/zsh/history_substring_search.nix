{
  pkgs,
  ...
}:
{
  programs.zsh.plugins = [
    {
      name = "zsh-history-substring-search";
      src = pkgs.zsh-history-substring-search;
      file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
    }
  ];
}
