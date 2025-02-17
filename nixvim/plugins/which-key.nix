{ unstable, ... }:
{
  programs.nixvim = {
    plugins.which-key = {
      enable = true;
      package = unstable.vimPlugins.which-key-nvim;
      lazyLoad.settings.event = [ "DeferredUIEnter" ];
    };
  };
}
