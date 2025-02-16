{
  programs.nixvim = {
    plugins.nvim-ufo = {
      enable = true;
      lazyLoad.settings.event = [ "BufRead" ];
    };
    opts = {
      foldcolumn = "1";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
    };
    keymaps = [
      {
        action = ''<cmd>lua require('ufo').openAllFolds()<CR>'';
        key = "zR";
        options = {
          silent = true;
          desc = "(UFO) Open All Folders";
        };
      }
      {
        action = ''<cmd>lua require('ufo').closeAllFolds()<CR>'';
        key = "zM";
        options = {
          silent = true;
          desc = "(UFO) Close All Folders";
        };
      }
    ];
  };
}
