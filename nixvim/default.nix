{ pkgs, inputs, ... }:
{
  imports = [
    ./plugins

    ./autocmd.nix
    ./neovide.nix
  ];
  # Dependencies are not defined here, but whoever imports this module.
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        transparent_background = true;
        # integrations = {
        #   blink_cmp = true;
        #   grug_far = true;
        #   neotest = true;
        #   noice = true;
        #   ufo = true;
        #   snacks = {
        #     enabled = true;
        #     indent_scope_color = "lavender";
        #   };
        #   lsp_trouble = true;
        #   vim-dadbod-ui = true;
        #   which_key = true;
        # };
      };
    };
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    extraPackages = with pkgs; [
      ripgrep
      fd
    ];
    # Space key has to be set to NOP for setting leader key to space to work.
    #
    # Also sets <leader>Q as macro key so no accidental macro presses
    extraConfigLuaPre = # lua
      ''
        vim.keymap.set("", "<Space>", "<Nop>", {})
        vim.keymap.set("", "q", "<Nop>", {})
        vim.keymap.set("", "<leader>Q", "q", { desc = "Record Macro" })
      '';
    keymaps = import ./keymaps.nix;
    globals = {
      # Set leader key to space.
      mapleader = " ";
      maplocalleader = "\\";
    };
    opts = import ./opts.nix;
  };
}
