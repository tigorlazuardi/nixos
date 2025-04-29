{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib.strings) optionalString;
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
    autosuggestion.enable = false;
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
    initContent =
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

        # create a zkbd compatible hash;
        # to add other keys to this hash, see: man 5 terminfo
        typeset -g -A key

        key[Home]="''${terminfo[khome]}"
        key[End]="''${terminfo[kend]}"
        key[Insert]="''${terminfo[kich1]}"
        key[Backspace]="''${terminfo[kbs]}"
        key[Delete]="''${terminfo[kdch1]}"
        key[Up]="''${terminfo[kcuu1]}"
        key[Down]="''${terminfo[kcud1]}"
        key[Left]="''${terminfo[kcub1]}"
        key[Right]="''${terminfo[kcuf1]}"
        key[PageUp]="''${terminfo[kpp]}"
        key[PageDown]="''${terminfo[knp]}"
        key[Shift-Tab]="''${terminfo[kcbt]}"

        # setup key accordingly
        [[ -n "''${key[Home]}"      ]] && bindkey -- "''${key[Home]}"       beginning-of-line
        [[ -n "''${key[End]}"       ]] && bindkey -- "''${key[End]}"        end-of-line
        [[ -n "''${key[Insert]}"    ]] && bindkey -- "''${key[Insert]}"     overwrite-mode
        [[ -n "''${key[Backspace]}" ]] && bindkey -- "''${key[Backspace]}"  backward-delete-char
        [[ -n "''${key[Delete]}"    ]] && bindkey -- "''${key[Delete]}"     delete-char
        [[ -n "''${key[Up]}"        ]] && bindkey -- "''${key[Up]}"         up-line-or-history
        [[ -n "''${key[Down]}"      ]] && bindkey -- "''${key[Down]}"       down-line-or-history
        [[ -n "''${key[Left]}"      ]] && bindkey -- "''${key[Left]}"       backward-char
        [[ -n "''${key[Right]}"     ]] && bindkey -- "''${key[Right]}"      forward-char
        [[ -n "''${key[PageUp]}"    ]] && bindkey -- "''${key[PageUp]}"     beginning-of-buffer-or-history
        [[ -n "''${key[PageDown]}"  ]] && bindkey -- "''${key[PageDown]}"   end-of-buffer-or-history
        [[ -n "''${key[Shift-Tab]}" ]] && bindkey -- "''${key[Shift-Tab]}"  reverse-menu-complete

        # Finally, make sure the terminal is in application mode, when zle is
        # active. Only then are the values from $terminfo valid.
        if (( ''${+terminfo[smkx]} && ''${+terminfo[rmkx]} )); then
            autoload -Uz add-zle-hook-widget
            function zle_application_mode_start { echoti smkx }
            function zle_application_mode_stop { echoti rmkx }
            add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
            add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
        fi
        export ZSH_CACHE_DIR=$HOME/.cache/zsh

        # _ZSH_COLOR_SCHEME_FILE=$HOME/.cache/wallust/sequences
        # if [ -f "$_ZSH_COLOR_SCHEME_FILE" ]; then
        #     (cat "$_ZSH_COLOR_SCHEME_FILE" &)
        # fi

        mkdir -p $ZSH_CACHE_DIR/completions
        fpath+=$ZSH_CACHE_DIR/completions
        fpath+=${pkgs.zsh-completions}/share/zsh/site-functions

        ${
          (optionalString config.profile.podman.enable # sh
            ''
              if [ ! -f $ZSH_CACHE_DIR/completions/_podman ]; then
                  podman completion zsh > $ZSH_CACHE_DIR/completions/_podman
              fi

              function pod-ips() {
                sudo podman inspect --format '{{.Name}} - {{.NetworkSettings.IPAddress}}' $(sudo podman ps -q) | sort -t . -k 3,4
              }
            ''
          )
        }
      '';

    plugins = [
      {
        name = "zsh-f-sy-h";
        src = pkgs.zsh-f-sy-h;
        file = "share/zsh/site-functions/F-Sy-H.plugin.zsh";
      }
      {
        name = "zsh-autocomplete";
        src = pkgs.zsh-autocomplete.overrideAttrs (old: {
          version = inputs.zsh-autocomplete.shortRev;
          src = inputs.zsh-autocomplete;
          installPhase = ''
            ls -la
            mkdir -p $out/share/zsh-autocomplete
            install -D zsh-autocomplete.plugin.zsh $out/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
            cp -R Functions $out/share/zsh-autocomplete/Functions
            cp -R Completions $out/share/zsh-autocomplete/Completions
          '';
        });
        file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
      }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
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
        # type commands that will output json
        # press alt-j
        name = "jq-zsh-plugin";
        src = pkgs.jq-zsh-plugin;
        file = "share/jq-zsh-plugin/jq.plugin.zsh";
      }
      {
        name = "auto-suggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh";
      }
    ];
  };
}
