{ inputs, pkgs, ... }:
{
  imports = [
    inputs.stylix.homeManagerModules.stylix
  ];

  stylix = {
    enable = true;
    image = ../home/modules/hyprland/wallpaper.jpeg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    targets = {
      lazygit.enable = true;
      nixvim.transparentBackground = {
        main = true;
        signColumn = true;
      };
    };
    opacity = {
      applications = 1.0;
      desktop = 0.6;
      terminal = 0.9;
    };
  };
}
