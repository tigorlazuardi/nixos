{ unstable, ... }:
{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      package = unstable.vimPlugins.nvim-treesitter;
    };
    treesitter-context = {
      enable = true;
      package = unstable.vimPlugins.nvim-treesitter-context;
      settings = {
        enable = true;
        max_lines = 1;
      };
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufWritePost"
        "BufNewFile"
      ];
    };
  };
}
