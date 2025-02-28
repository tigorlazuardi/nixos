{ inputs, ... }:
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];
  catppuccin = {
    enable = true;
    flavor = "mocha";
    gtk.enable = true;
    zellij.enable = false;
  };
}
