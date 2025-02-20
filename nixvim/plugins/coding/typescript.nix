{ unstable, ... }:
{
  programs.nixvim = {
    plugins = {
      none-ls.sources.formatting.prettierd = {
        enable = true;
        package = unstable.prettierd;
        disableTsServerFormatter = true;
      };
      typescript-tools = {
        enable = true;
        package = unstable.vimPlugins.typescript-tools-nvim;
        lazyLoad.settings.ft = [
          "typescript"
          "typescriptreact"
          "javascript"
          "javascriptreact"
          "svelte"
          "astro"
          "vue"
        ];
      };
    };
  };
}
