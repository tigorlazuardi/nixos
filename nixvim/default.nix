{ pkgs, ... }:
{
  imports = [
    ./plugins

    ./autocmd.nix
  ];
  # Dependencies are not defined here, but whoever imports this module.
  programs.nixvim = {
    enable = true;
    colorschemes.catppuccin = {
      enable = true;
      settings.transparent_background.__raw = "vim.g.neovide or false";
    };
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
    # Neovide config
    extraConfigLua = ''
      if vim.g.neovide then
        local font = "JetBrainsMono Nerd Font"

        local font_size = vim.o.lines < 60 and 11 or 12

        vim.o.guifont = font .. ":h" .. font_size
        vim.g.neovide_transparency = 0.7
        vim.g.transparency = 0.8
        vim.g.neovide_window_blurred = true

        vim.keymap.set("n", "<c-->", function()
          font_size = font_size - 1
          vim.o.guifont = font .. ":h" .. font_size
          vim.notify("Font Set: " .. font .. ":h" .. font_size)
        end, { desc = "Decrease font size" })

        vim.keymap.set("n", "<c-=>", function()
          font_size = font_size + 1
          vim.o.guifont = font .. ":h" .. font_size
          vim.notify("Font Set: " .. font .. ":h" .. font_size)
        end, { desc = "Increase font size" })
      end
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
