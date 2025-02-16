{ unstable, ... }:
{
  programs.nixvim = {
    plugins.fidget = {
      enable = true;
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
