{ config, lib, ... }:
let
  cfg = config.profile.home.programs.foot;
in
{
  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          dpi-aware = "yes";
          font = cfg.font;
          include = lib.mkIf config.profile.hyprland.enable "${config.home.homeDirectory}/.config/foot/colors.ini";
          selection-target = "both";
        };
        mouse = {
          hide-when-typing = "yes";
        };
        cursor = {
          style = "beam";
          blink = "yes";
        };
        bell = {
          notify = "yes";
        };
      };
    };

    programs.zsh.initExtra = # bash
      ''
        function osc7-pwd() {
            emulate -L zsh # also sets localoptions for us
            setopt extendedglob
            local LC_ALL=C
            printf '\e]7;file://%s%s\e\' $HOST ''${PWD//(#m)([^@-Za-z&-;_~])/%''${(l:2::0:)$(([##16]#MATCH))}}
        }

        function chpwd-osc7-pwd() {
            (( ZSH_SUBSHELL )) || osc7-pwd
        }
        add-zsh-hook -Uz chpwd chpwd-osc7-pwd
      '';
  };
}
