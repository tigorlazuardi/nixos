{ pkgs, ... }:
{
  imports = [
    ./plugins
  ];
  # Dependencies are not defined here, but whoever imports this module.
  programs.nixvim = {
    enable = true;
    colorschemes.catppuccin.enable = true;
    plugins = {
      treesitter.enable = true;
    };
    extraPackages = with pkgs; [
      ripgrep
      fd
      universal-ctags
    ];
    globals = import ./globals.nix;
    opts = import ./opts.nix;
  };
}
