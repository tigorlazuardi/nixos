{ config, lib, ... }:
let
  cfg = config.profile.kitty;
in
{
  config = lib.mkIf cfg.enable {
    home.file.".config/wallust/templates/kitty.conf".text =
      # css
      ''
        foreground         {{foreground}}
        background         {{background}}
        background_opacity {{ alpha / 100 }}
        cursor             {{cursor}}

        active_tab_foreground     {{background}}
        active_tab_background     {{foreground}}
        inactive_tab_foreground   {{foreground}}
        inactive_tab_background   {{background}}

        active_border_color   {{foreground}}
        inactive_border_color {{background}}
        bell_border_color     {{color1}}

        color0       {{color0}}
        color1       {{color1}}
        color2       {{color2}}
        color3       {{color3}}
        color4       {{color4}}
        color5       {{color5}}
        color6       {{color6}}
        color7       {{color7}}
        color8       {{color8}}
        color9       {{color9}}
        color10      {{color10}}
        color11      {{color11}}
        color12      {{color12}}
        color13      {{color13}}
        color14      {{color14}}
        color15      {{color15}}
      '';

    profile.hyprland.wallust.settings.templates.kitty = {
      template = "kitty.conf";
      target = "${config.home.homeDirectory}/.config/kitty/kitty.d/99-colors.conf";
    };

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
        background_blur = 40;
        background_opacity = toString 0.9;
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
      extraConfig = ''
        globinclude kitty.d/**/*.conf
      '';
    };
  };
}
