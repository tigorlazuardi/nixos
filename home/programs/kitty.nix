{
  config,
  lib,
  ...
}:
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
        background_blur = 40;
        background_opacity = toString 0.9;
        cursor_blink_interval = toString 0.5;
      };
      font = {
        name = "JetBrainsMono Nerd Font Mono";
        size = 11;
      };
    };
    stylix.targets.kitty.enable = true;
  };
}
