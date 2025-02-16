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
    ts-context-commentstring = {
      enable = true;
      extraOptions.enable_autocmd = false;
    };
    mini.modules.comment.options.custom_commentstring.__raw = # lua
      ''
        function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end
      '';
  };
}
