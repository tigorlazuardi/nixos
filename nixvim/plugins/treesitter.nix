{ unstable, inputs, ... }:
{
  # smartindent settings are interfering with treesitter
  programs.nixvim.opts.smartindent = unstable.lib.mkForce false;
  programs.nixvim.extraPlugins = [
    {
      plugin = unstable.vimPlugins.nvim-treesitter-endwise;
      optional = true;
    }
    {
      plugin = unstable.vimPlugins.ultimate-autopair-nvim;
      optional = true;
    }
    {
      plugin = unstable.vimUtils.buildVimPlugin {
        pname = "neotab.nvim";
        src = inputs.neotab-nvim;
        version = inputs.neotab-nvim.shortRev;
      };
      optional = true;
    }
  ];
  programs.nixvim.extraConfigLua = ''
    require("lz.n").load {
      {
        "nvim-treesitter-endwise",
        event = "InsertEnter",
      },
      {
        "ultimate-autopair.nvim",
        event = "InsertEnter",
        after = function() require("ultimate-autopair").setup {} end,
      },
      {
        "neotab.nvim",
        event = "InsertEnter",
        after = function()
          require("neotab").setup {
            tabkey = "",
            smart_puncuators = {
              enabled = true,
              semicolon = {
                enabled = true,
                ft = { "cs", "c", "cpp", "java", "nix", "rust" },
              },
            },
          }
          vim.keymap.set("i", "<tab>", function()
            if require("copilot.suggestion").is_visible() then
              require("copilot.suggestion").accept()
            else
              require("neotab").tabout()
            end
          end, {
            silent = true,
          })
        end,
      },
    }
  '';
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      package = unstable.vimPlugins.nvim-treesitter;
      treesitterPackage = unstable.tree-sitter;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };
    ts-autotag = {
      enable = true;
      package = unstable.vimPlugins.nvim-ts-autotag;
      settings = {
        opts.enable_close_on_slash = true;
      };
      lazyLoad.settings.ft = [
        "html"
        "gohtml"
        "javascriptreact"
        "typescriptreact"
        "svelte"
        "vue"
        "tmpl"
        "astro"
        "markdown"
        "php"
        "twig"
        "blade"
        "xml"
      ];
    };
    ts-comments = {
      enable = true;
      package = unstable.vimPlugins.ts-comments-nvim;
      settings = {
        opts.ignore_whitespace = true;
      };
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
