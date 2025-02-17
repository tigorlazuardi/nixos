{ pkgs, ... }:
{
  imports = [
    ./plugins
  ];
  # Dependencies are not defined here, but whoever imports this module.
  programs.nixvim = {
    enable = true;
    colorschemes.catppuccin.enable = true;
    extraPackages = with pkgs; [
      ripgrep
      fd
      universal-ctags

      go
      gopls
      gotools
      go-tools
      gofumpt
      gomodifytags
      impl
    ];
    # Space key has to be set to NOP for setting leader key to space to work.
    #
    # Also sets <leader>Q as macro key so no accidental macro presses
    extraConfigLuaPre = # lua
      ''
        vim.keymap.set("", "<Space>", "<Nop>", {})
        vim.keymap.set("", "q", "<Nop>", {})
        vim.keymap.set("", "<leader>Q", "q", {desc = "Record Macro"})
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
