{ unstable, ... }:
{
  programs.nixvim = {
    plugins.none-ls = {
      enable = true;
      package = unstable.vimPlugins.none-ls-nvim;
    };
  };
}
