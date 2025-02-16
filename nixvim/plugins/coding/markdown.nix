{
  programs.nixvim = {
    extraConfigLua = # lua
      ''
        require('lz.n').load({
            "markdown-preview.nvim",
            ft = "markdown",
        })
      '';
    plugins = {
      markdown-preview = {
        enable = true;
        autoLoad = false;
      };
      render-markdown = {
        enable = true;
        lazyLoad.settings.ft = [ "markdown" ];
      };
    };
  };
}
