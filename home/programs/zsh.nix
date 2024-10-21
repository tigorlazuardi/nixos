{ pkgs
, lib
, config
, ...
}:
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
    envExtra = # bash
      ''
        # Disable loading global RC files in /etc/zsh/*
        # Mostly because they are unneeded
        # and global rc files has to be small for security reasons (no plugins)
        # thus making them saver for Root account to load them.
        unsetopt GLOBAL_RCS
      '';
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
      ls = "${pkgs.eza}/bin/eza -lah";
      cat = "${pkgs.bat}/bin/bat";
      update = "nh os switch";
      superupdate = "nh os switch --update";
      uptest = "nh os test";
      lg = "${pkgs.lazygit}/bin/lazygit";
      g = "${pkgs.lazygit}/bin/lazygit";
      du = "${pkgs.dust}/bin/dust";
      dry = "sudo nixos-rebuild dry-activate --flake $HOME/dotfiles";
      jq = "${pkgs.gojq}/bin/gojq";
      n = lib.mkIf config.profile.neovide.enable "neovide";
      v = "nvim";
      cd = "z";
      grep = "${pkgs.ripgrep}/bin/rg";
      find = "${pkgs.fd}/bin/fd";
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
    syntaxHighlighting.enable = true;
    initExtraFirst = lib.mkOrder 9999 (concatStrings [
      # bash
      ''
        export ZSH_CACHE_DIR=$HOME/.cache/zsh

        _ZSH_COLOR_SCHEME_FILE=$HOME/.cache/wallust/sequences
        if [ -f "$_ZSH_COLOR_SCHEME_FILE" ]; then
            (cat "$_ZSH_COLOR_SCHEME_FILE" &)
        fi

        mkdir -p $ZSH_CACHE_DIR/completions
        fpath+=$ZSH_CACHE_DIR/completions
        fpath+=${pkgs.zsh-completions}/share/zsh/site-functions
      ''
      (optionalString config.profile.podman.enable # bash
        ''
          if [ ! -f $ZSH_CACHE_DIR/completions/_podman ]; then
              podman completion zsh > $ZSH_CACHE_DIR/completions/_podman
          fi
        ''
      )
    ]);
    initExtra = concatStrings [
      # bash
      ''
        packfiles() {
          find $(NIXPKGS_ALLOW_UNFREE=1 nix build "nixpkgs#$1" --impure --no-link --print-out-paths) 
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
      {
        name = "zsh-autocomplete";
        src = pkgs.zsh-autocomplete;
        file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
      }
      # {
      #   name = "zsh-defer";
      #   src = pkgs.zsh-defer;
      #   file = "share/zsh-defer/zsh-defer.plugin.zsh";
      # }
    ];
  };
}
