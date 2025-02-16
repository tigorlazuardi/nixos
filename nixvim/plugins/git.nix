{
  programs.nixvim = {
    extraConfigLua = # lua
      ''
        require('lz.n').load({
            "gitignore.nvim",
            cmd = "Gitignore",
        })
      '';
    plugins = {
      gitsigns = {
        enable = true;
        lazyLoad.settings.event = [
          "BufReadPost"
        ];
        settings = {
          current_line_blame = true;
        };
      };
      gitignore = {
        enable = true;
        autoLoad = false;
      };
    };
  };
}
