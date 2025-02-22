{ unstable, ... }:
{
  imports = [
    ./aider.nix
    ./codecompanion.nix
    ./copilot.nix
    ./go.nix
    ./lua.nix
    ./markdown.nix
    ./neotest.nix
    ./nix.nix
    ./svelte.nix
    ./tiny-code-action.nix
    ./typescript.nix
  ];

  programs.nixvim = {
    # Diagnostic will color the number if exist.
    extraConfigLua = ''
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
          },
          numhl = {
            [vim.diagnostic.severity.WARN] = 'WarningMsg',
            [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
            [vim.diagnostic.severity.INFO] = 'DiagnosticInfo',
            [vim.diagnostic.severity.HINT] = 'DiagnosticHint',
          },
        },
      })
    '';
    # Lspconfig
    plugins.lsp = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufWritePost"
        "BufNewFile"
      ];
    };
    plugins.conform-nvim = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufWritePost"
        "BufNewFile"
      ];
      luaConfig.post = # lua
        ''
          vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        '';
      settings = {
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
      };
    };
    plugins.lint = {
      enable = true;
      package = unstable.vimPlugins.nvim-lint;
      autoCmd.event = [
        "BufWritePost"
        "BufReadPost"
        "InsertLeave"
      ];
      lazyLoad.settings.event = [
        "BufWritePost"
        "BufNewFile"
        "InsertEnter"
      ];
    };
  };
}
