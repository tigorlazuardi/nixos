{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.profile.home.programs.ghostty;
in
{
  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        theme = "catppuccin-mocha";
        font-family = "Hack Nerd Font Mono";
        font-size = 11;
        copy-on-select = "clipboard";
        window-decoration = false;
        linux-cgroup = "always";
        background-opacity = 0.8;
        clipboard-trim-trailing-spaces = true;
        keybind = [
          "ctrl+a>t=new_tab"
          "ctrl+a>enter=new_split:right"
          "ctrl+a>backspace=new_split:down"
          "ctrl+a>l=goto_split:right"
          "ctrl+a>k=goto_split:top"
          "ctrl+a>j=goto_split:bottom"
          "ctrl+a>h=goto_split:left"
          "ctrl+a>space=toggle_split_zoom"
          "ctrl+a>r=reload_config"
          "ctrl+a>w=close_surface"
          "ctrl+a>1=goto_tab:1"
          "ctrl+a>2=goto_tab:2"
          "ctrl+a>3=goto_tab:3"
          "ctrl+a>4=goto_tab:4"
          "ctrl+a>5=goto_tab:5"
          "ctrl+a>6=goto_tab:6"
          "ctrl+a>7=goto_tab:7"
          "ctrl+a>8=goto_tab:8"
          "ctrl+a>9=goto_tab:9"
          "ctrl+a>0=goto_tab:10"
        ];
      };
      themes = {
        catppuccin-mocha = {
          background = "1e1e2e";
          cursor-color = "f5e0dc";
          foreground = "cdd6f4";
          palette = [
            "0=#45475a"
            "1=#f38ba8"
            "2=#a6e3a1"
            "3=#f9e2af"
            "4=#89b4fa"
            "5=#f5c2e7"
            "6=#94e2d5"
            "7=#bac2de"
            "8=#585b70"
            "9=#f38ba8"
            "10=#a6e3a1"
            "11=#f9e2af"
            "12=#89b4fa"
            "13=#f5c2e7"
            "14=#94e2d5"
            "15=#a6adc8"
          ];
          selection-background = "353749";
          selection-foreground = "cdd6f4";
        };
      };
    };
  };
}
