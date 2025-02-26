{ config, lib, ... }:
let
  cfg = config.profile.kitty;
in
{
  config = lib.mkIf cfg.enable {
    programs.zsh.initExtra = # bash
      ''
        if [[ "$TERM" == "xterm-kitty" ]]; then
            alias ssh="kitty +kitten ssh"
        fi
      '';
    programs.kitty = {
      enable = true;
      settings = {
        # General
        underline_hyperlinks = "always";
        enable_audio_bell = false;

        # Layouts
        enabled_layouts = "splits";

        # Window
        tab_bar_edge = "top";
        tab_bar_margin_width = toString 0.2;
        tab_bar_style = "slant";
        background_opacity = 0.8;
        background_blur = 40;
        cursor_blink_interval = toString 0.5;
      };
      keybindings = {
        "ctrl+a>enter" = "launch --location=vsplit --cwd=current";
        "ctrl+a>backspace" = "launch --location=hsplit --cwd=current";
        "ctrl+a>h" = "neighboring_window left";
        "ctrl+a>j" = "neighboring_window down";
        "ctrl+a>k" = "neighboring_window up";
        "ctrl+a>l" = "neighboring_window right";
        "ctrl+a>t" = "new_tab_with_cwd";
        "ctrl+a>w" = "close_window";
        "ctrl+a>r" = "start_resizing_window";
      };
      font = {
        name = "JetBrainsMono Nerd Font Mono";
        size = 11;
      };
    };
  };
}
