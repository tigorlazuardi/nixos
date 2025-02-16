{ unstable, ... }:
{
  programs.nixvim = {
    plugins.fidget = {
      enable = true;
      package = unstable.vimPlugins.fidget-nvim;
      lazyLoad.settings = {
        event = [ "DeferredUIEnter" ];
        after.__raw = # lua
          ''
            function()
                require('fidget').setup({})
                vim.notify = require('fidget').notify
            end
          '';
      };
    };
  };
}
