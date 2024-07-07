{ config, lib, unstable, pkgs, ... }:
let
  cfg = config.profile.go;
in
{
  config = lib.mkIf cfg.enable {
    programs.zsh.initExtra = ''zsh-defer source<(cat ${pkgs.zsh-completions}/share/zsh/site-functions/_golang)'';
    programs.go = {
      enable = true;
      goPrivate = [
        "gitlab.bareksa.com"
      ];
      package = unstable.go_1_22;
    };
  };
}
