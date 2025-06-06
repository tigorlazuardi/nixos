{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.profile.stylix.enable {
    programs.bat.enable = lib.mkForce true;
    programs.zsh.shellAliases.cat = lib.mkForce "${pkgs.bat}/bin/bat --theme=base16-stylix";
    stylix = {
      enable = true;
      image = ../home/modules/hyprland/wallpaper.jpeg;
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
      autoEnable = false;
      targets = {
        lazygit.enable = true;
        nixvim.enable = false;
        alacritty.enable = true;
        bat.enable = true;
        foot.enable = true;
        gtk.enable = true;
        hyprland.enable = true;
        hyprlock.enable = true;
        kitty.enable = true;
        waybar.enable = true;
      };
      opacity = {
        applications = 1.0;
        desktop = 0.6;
        terminal = 0.8;
      };
    };
  };
  imports = [
    inputs.stylix.homeModules.stylix
  ];
}
