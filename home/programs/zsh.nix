{ pkgs, lib, config, ... }:
let
  inherit (lib.strings) optionalString concatStrings;
in
{
  home.packages = with pkgs; [
    eza
    bat
    gojq
    nix-zsh-completions
  ];
  programs.zsh = {
    enable = true;
    envExtra = /*bash*/ ''
      # Disable loading global RC files in /etc/zsh/*
      # Mostly because they are unneeded
      # and global rc files has to be small for security reasons (no plugins)
      # thus making them saver for Root account to load them.
      unsetopt GLOBAL_RCS
    '';
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
      ls = "${pkgs.eza}/bin/eza -lah";
      cat = "${pkgs.bat}/bin/bat";
      # update = "sudo nixos-rebuild switch --flake $HOME/dotfiles";
      update = "nh os switch";
      # superupdate = "(cd $HOME/dotfiles && nix flake update && sudo nixos-rebuild switch --flake $HOME/dotfiles)";
      superupdate = "nh os switch --update";
      lg = "${pkgs.lazygit}/bin/lazygit";
      du = "${pkgs.dust}/bin/dust";
      uptest = "sudo nixos-rebuild test --flake $HOME/dotfiles";
      dry = "sudo nixos-rebuild dry-activate --flake $HOME/dotfiles";
      jq = "${pkgs.gojq}/bin/gojq";
      n = lib.mkIf config.profile.neovide.enable "neovide";
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
    completionInit = lib.mkOrder 9999 (concatStrings [
      /* bash */
      ''
        mkdir -p $ZSH_CACHE_DIR/completions
        fpath+=$ZSH_CACHE_DIR/completions
        fpath+=${pkgs.zsh-completions}/share/zsh/site-functions
      ''
      (optionalString config.profile.podman.enable /*bash*/ ''
        if [ ! -f $ZSH_CACHE_DIR/completions/_podman ]; then
            podman completion zsh > $ZSH_CACHE_DIR/completions/_podman
        fi
      '')
      # Value below must be always last in the completionInit
      /* bash */
      ''
        autoload -U compinit && compinit
      ''
    ]);
    syntaxHighlighting.enable = true;
    initExtraFirst = /*bash*/ ''
      export ZSH_CACHE_DIR=$HOME/.cache/zsh

      # if [ -f $HOME/.config/zsh/.p10k.zsh ]; then
      #     source $HOME/.config/zsh/.p10k.zsh
      # fi

      _ZSH_COLOR_SCHEME_FILE=$HOME/.cache/wallust/sequences
      if [ -f "$_ZSH_COLOR_SCHEME_FILE" ]; then
          (cat "$_ZSH_COLOR_SCHEME_FILE" &)
      fi
    '';
    initExtra = concatStrings [
      /*bash*/
      ''
        packfiles() {
          find $(nix build "nixpkgs#$1" --no-link --print-out-paths) 
        }

        build() {
            nix build --impure --expr "with import <nixpkgs> {}; callPackage $1 {}"
        }

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
        # preview directory's content with eza when completing z
        zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'
        # switch group using `<` and `>`
        zstyle ':fzf-tab:*' switch-group '<' '>'
      ''
    ];

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      # {
      #   name = "powerlevel10k";
      #   src = pkgs.zsh-powerlevel10k;
      #   file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      # }
      {
        name = "auto-suggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh";
      }
      {
        name = "zsh-nix-shell";
        src = pkgs.zsh-nix-shell;
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
      }
      {
        name = "zsh-history-substring-search";
        src = pkgs.zsh-history-substring-search;
        file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
      # {
      #   name = "zsh-defer";
      #   src = pkgs.zsh-defer;
      #   file = "share/zsh-defer/zsh-defer.plugin.zsh";
      # }
    ];
  };
}
