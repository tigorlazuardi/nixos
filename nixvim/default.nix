{ pkgs, inputs, ... }:
{
  imports = [
    ./plugins

    ./autocmd.nix
    ./neovide.nix
    ./keymaps.nix
    ./colorscheme.nix
  ];
  # Dependencies are not defined here, but whoever imports this module.
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    extraPackages = with pkgs; [
      ripgrep
      fd
      wgo
    ];
    # Space key has to be set to NOP for setting leader key to space to work.
    #
    # Also sets <leader>Q as macro key so no accidental macro presses
    extraConfigLuaPre = # lua
      ''
        if vim.env.SSH_TTY then
          vim.g.clipboard = "osc52"
        end
        vim.keymap.set("", "<Space>", "<Nop>", {})
        vim.keymap.set("", "q", "<Nop>", {})
        vim.keymap.set("", "<leader>Q", "q", { desc = "Record Macro" })
      '';
    globals = {
      # Set leader key to space.
      mapleader = " ";
      maplocalleader = "\\";
    };
    opts = import ./opts.nix;
  };
}
