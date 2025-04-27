{ config, lib, ... }:
let
  cfg = config.profile.programs.wezterm;
in
{
  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;

      extraConfig = # lua
        ''
          -- take config from ./base_config.lua
          local config = require('base_config')

          -- and override settings for nixos specific things here.
          config.window_background_opacity = ${toString cfg.config.window_background_opacity};

          return config
        '';
    };

    programs.zsh.initContent = # bash
      ''
        if [ -n "$WEZTERM_PANE" ]; then
            alias ssh="wezterm ssh"
        fi
      '';

    home.file.".config/wezterm" = {
      source = ./.;
      recursive = true;
    };
  };
}
