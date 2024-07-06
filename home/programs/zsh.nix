{ pkgs, lib, config, ... }:
let
  inherit (lib.lists) optional;
in
{
  home.packages = with pkgs; [
    eza
    bat
    gojq
  ];
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
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
      n = "neovide";
      v = "nvim";
      cd = "z";
    };
    dotDir = ".config/zsh";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      path = "$HOME/.local/share/zsh/zsh_history";
      save = 40000;
      size = 40000;
    };
    initExtraFirst = /*bash*/ ''
      _ZSH_COLOR_SCHEME_FILE=$HOME/.cache/wallust/sequences
      if [ -f "$_ZSH_COLOR_SCHEME_FILE" ]; then
          (cat "$_ZSH_COLOR_SCHEME_FILE" &)
      fi
    '';
    initExtra = /*bash*/ ''

      # Completion settings
      ## Case insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # FZF Tab configurations
      #
      # disable sort when completing `git checkout`
      zstyle ':completion:*:git-checkout:*' sort false
      # set descriptions format to enable group support
      # NOTE: don't use escape sequences here, fzf-tab will ignore them
      zstyle ':completion:*:descriptions' format '[%d]'
      # set list-colors to enable filename colorizing
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
      zstyle ':completion:*' menu no
      # preview directory's content with eza when completing cd
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      # switch group using `<` and `>`
      zstyle ':fzf-tab:*' switch-group '<' '>'
      # Preview fzf
      zstyle ':fzf-tab:*' fzf-preview 'eza -1 --color=always $realpath'
    '';
    antidote = {
      enable = true;
      plugins = [
        "zdharma-continuum/fast-syntax-highlighting kind:defer"
        "zsh-users/zsh-autosuggestions kind:defer"
        "zsh-users/zsh-history-substring-search kind:defer"
        "zsh-users/zsh-completions"
        "Aloxaf/fzf-tab"

        "ohmyzsh/ohmyzsh path:plugins/golang"
      ]
      ++ optional (config.profile.podman.enable) "ohmyzsh/ohmyzsh path:plugins/podman"
      ;
    };
  };
}
