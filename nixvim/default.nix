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
    extraConfigLuaPre = /* lua */
      ''
        vim.keymap.set("", "<Space>", "<Nop>", {})
      '';
    globals = {
      # Set leader key to space.
      mapleader = " ";
      maplocalleader = "\\";
    };
    opts = import ./opts.nix;
  };
}
