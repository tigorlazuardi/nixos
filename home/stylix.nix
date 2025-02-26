{ inputs, pkgs, ... }:
{
  imports = [
    inputs.stylix.homeManagerModules.stylix
  ];

  stylix = {
    enable = false;
    image = ../home/modules/hyprland/wallpaper.jpeg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    targets = {
      lazygit.enable = true;
      nixvim.enable = false;
    };
    opacity = {
      applications = 1.0;
      desktop = 0.6;
      terminal = 0.9;
    };
  };
}
