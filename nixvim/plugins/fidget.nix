{ unstable, ... }:
{
  programs.nixvim = {
    plugins.fidget = {
      enable = false;
      package = unstable.vimPlugins.fidget-nvim;
      luaConfig.post = # lua
        ''
          vim.notify = require('fidget').notify
        '';
      lazyLoad.settings = {
        event = [ "DeferredUIEnter" ];
      };
    };
  };
}
