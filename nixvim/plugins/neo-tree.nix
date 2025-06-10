{
  programs.nixvim = {
    plugins.neo-tree = {
      enable = true;
    };
    keymaps = [
      {
        action = "<cmd>Neotree toggle<cr>";
        key = "<leader>e";
        mode = "n";
        options.desc = "Toggle Neo-tree";
      }
    ];
  };
}
