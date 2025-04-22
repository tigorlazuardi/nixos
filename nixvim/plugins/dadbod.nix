{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimPlugins.vim-dadbod;
        optional = true;
      }
      {
        plugin = pkgs.vimPlugins.vim-dadbod-completion;
        optional = true;
      }
      {
        plugin = pkgs.vimPlugins.vim-dadbod-ui;
        optional = true;
      }
    ];
    extraConfigLua = ''
      require("lz.n").load {
        { "vim-dadbod" },
        {
          "vim-dadbod-ui",
          cmd = { "DB", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
          before = function() vim.g.db_ui_use_nerd_fonts = 1 end,
        },
        {
          "vim-dadbod-completion",
          ft = { "sql", "mysql", "plsql", "pgsql", "sqlite" },
        },
      }
    '';
    plugins.blink-cmp.settings.sources = {
      per_filetype.sql = [
        "snippets"
        "dadbod"
        "buffer"
      ];
      providers.dadbod = {
        name = "Dadbod";
        module = "vim_dadbod_completion.blink";
      };
    };
  };
}
