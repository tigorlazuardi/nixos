{ unstable, ... }:
{
  programs.nixvim = {
    plugins.which-key = {
      enable = true;
      package = unstable.vimPlugins.which-key-nvim;
      lazyLoad.settings.event = [ "DeferredUIEnter" ];
    };
    keymaps = [
      {
        action = "";
        key = "<leader>c";
        mode = "n";
        options.desc = "+code";
      }
    ];
  };
}
