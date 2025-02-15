{ inputs, pkgs, ... }:
{
  imports = [
    ./plugins
  ];
  # Dependencies are not defined here, but whoever imports this module.
  programs.nixvim = {
    enable = true;
    colorschemes.catppuccin = {
      enable = false;
      autoLoad = true;
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "catppuccin-nvim";
        src = inputs.catppuccin-nvim;
        version = inputs.catppuccin-nvim.shortRev;
      };
    };
  };
}
