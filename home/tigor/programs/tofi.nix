{ pkgs, config, lib, ... }:
let
  cfg = config.profile.tofi;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ tofi ];
    home.file = {
      ".config/tofi/neovide.zsh" = {
        executable = true;
        text = ''
          #/usr/bin/env zsh
          folder=$(zoxide query --list | tofi)
          [[ -z "$folder" ]] || (zsh -c "cd \"$folder\"; neovide --maximized")
        '';
      };

      ".config/tofi/config" = {
        text = ''
          width = 100%
          height = 100%
          border-width = 0
          outline-width = 0
          padding-left = 35%
          padding-top = 35%
          result-spacing = 25
          num-results = 5
          font = monospace
          background-color = #000A
        '';
      };
    };
  };
}
