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
    };

    home.file.".config/wezterm" = {
      source = ./.;
      recursive = true;
    };
  };
}
