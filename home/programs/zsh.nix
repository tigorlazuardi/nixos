{ pkgs, ... }:

{
  home.packages = with pkgs; [
    eza
    bat
    gojq
  ];
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = false;
    defaultKeymap = "emacs";
    dirHashes = {
      docs = "$HOME/Documents";
      dl = "$HOME/Downloads";
      videos = "$HOME/Videos";
      pictures = "$HOME/Pictures";
    };
    shellAliases = {
      ls = "eza -lah";
      cat = "bat";
      update = "sudo nixos-rebuild switch --flake $HOME/dotfiles";
      superupdate = "(cd $HOME/dotfiles && nix flake update && sudo nixos-rebuild switch --flake $HOME/dotfiles)";
      lg = "lazygit";
      du = "dust -H";
      uptest = "sudo nixos-rebuild test --flake $HOME/dotfiles";
      dry = "sudo nixos-rebuild dry-activate --flake $HOME/dotfiles";
      jq = "gojq";
      n = "neovide --fork";
      v = "nvim";
    };
    dotDir = ".config/zsh";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreAllDups = true;
      path = "$HOME/.local/share/zsh/zsh_history";
      save = 40000;
      size = 40000;
    };
    initExtraFirst = ''
      _ZSH_COLOR_SCHEME_FILE=$HOME/.cache/wallust/sequences
      if [ -f "$_ZSH_COLOR_SCHEME_FILE" ]; then
          (cat "$_ZSH_COLOR_SCHEME_FILE" &)
      fi
    '';
    initExtra = ''
      bindkey              '^I'         menu-complete
      bindkey "$terminfo[kcbt]" reverse-menu-complete
    '';
    antidote = {
      enable = true;
      plugins = [
        # "zdharma-continuum/fast-syntax-highlighting kind:defer"
        "zsh-users/zsh-autosuggestions kind:defer"
        "zsh-users/zsh-history-substring-search kind:defer"
        "zsh-users/zsh-completions"
        "marlonrichert/zsh-autocomplete"
      ];
    };
  };
}
