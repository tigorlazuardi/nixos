{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib.strings) optionalString concatStrings;
in
{
  home.packages = with pkgs; [
    eza
    gojq
    tre-command
  ];
  programs.bat.enable = true;
  programs.btop.enable = true;
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
      update = "nh os switch -- --accept-flake-config";
      superupdate = "nh os switch --update -- --accept-flake-config";
      uptest = "nh os test -- --accept-flake-config";
      lg = "${pkgs.lazygit}/bin/lazygit";
      g = "${pkgs.lazygit}/bin/lazygit";
      du = "${pkgs.dust}/bin/dust";
      dry = "sudo nixos-rebuild dry-activate --flake $HOME/dotfiles";
      jq = "${pkgs.gojq}/bin/gojq";
      v = "nvim";
      cd = "z";
      grep = "${pkgs.ripgrep}/bin/rg";
      find = "${pkgs.fd}/bin/fd";
      tree = "${pkgs.tre-command}/bin/tre";
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
    syntaxHighlighting.enable = false;
    initExtraFirst = lib.mkOrder 9999 (concatStrings [
      # bash
      ''
        export ZSH_CACHE_DIR=$HOME/.cache/zsh

        # _ZSH_COLOR_SCHEME_FILE=$HOME/.cache/wallust/sequences
        # if [ -f "$_ZSH_COLOR_SCHEME_FILE" ]; then
        #     (cat "$_ZSH_COLOR_SCHEME_FILE" &)
        # fi

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

        nf() {
            local selected=$(zoxide query --list | fzf)
            if [ -n "$selected" ]; then
                cd "$selected"
                neovide
            fi
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

        if [[ -f "/var/lib/rust-motd/motd" ]]; then
            ${pkgs.coreutils}/bin/cat /var/lib/rust-motd/motd
        fi
      ''
    ];

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
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
        # bug fix crashes for zsh. Use old version for now.
        src = pkgs.zsh-autocomplete.overrideAttrs (old: rec {
          version = "23.05.24";
          src = pkgs.fetchFromGitHub {
            owner = "marlonrichert";
            repo = "zsh-autocomplete";
            rev = version;
            sha256 = "sha256-/6V6IHwB5p0GT1u5SAiUa20LjFDSrMo731jFBq/bnpw=";
          };
          installPhase = ''
            ls -la
            mkdir -p $out/share/zsh-autocomplete
            install -D zsh-autocomplete.plugin.zsh $out/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
            cp -R functions $out/share/zsh-autocomplete/functions
            cp -R scripts $out/share/zsh-autocomplete/scripts
          '';
        });
        file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
      }
      {
        # type commands that will output json
        # press alt-j
        name = "jq-zsh-plugin";
        src = pkgs.jq-zsh-plugin;
        file = "share/jq-zsh-plugin/jq.plugin.zsh";
      }
      {
        name = "zsh-f-sy-h";
        src = pkgs.zsh-f-sy-h;
        file = "share/zsh/site-functions/F-Sy-H.plugin.zsh";
      }
    ];
  };
}
