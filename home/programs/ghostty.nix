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
    };
  };
}
