{
  pkgs,
  lib,
  ...
}:
{
  programs.zsh = {
    initContent =
      lib.mkOrder 100 # bash
        ''
          ZSH_AUTOSUGGEST_STRATEGY=(history completion)
          ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c500,)"
        '';
    plugins = [
      {
        name = "auto-suggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
    ];
  };
}
