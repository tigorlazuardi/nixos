{ lib, config, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        import = [
          "${config.home.homeDirectory}/.cache/wallust/alacritty.toml"
        ];
        live_config_reload = true;
        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Italic";
          };
          bold = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold";
          };
          bold_italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold Italic";
          };
          size = 11.0;
        };
      };
    };
  };
}
