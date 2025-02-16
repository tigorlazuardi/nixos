{ unstable, ... }:
{
  imports = [
    ./lua.nix
    ./nix.nix
    ./markdown.nix
  ];

  programs.nixvim = {
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
      lazyLoad.settings.event = [
        "BufWritePost"
        "BufNewFile"
        "InsertLeave"
      ];
    };
  };
}
