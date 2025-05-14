{ pkgs, ... }:
{

  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = "";
      fish_prompt = # fish
        ''
          set -l prompt_color (set_color $fish_color_cwd)
          set -l prompt_symbol (set_color $fish_color_cwd) '❯'
          set -l prompt (set_color $fish_color_cwd) (prompt_pwd) $prompt_symbol
          echo -n $prompt
        '';
      packfiles = # fish
        ''
          set -lx NIXPKGS_ALLOW_UNFREE 1
          nix build "nixpkgs#$argv[1]" --impure --no-link --print-out-paths
        '';
      build = # fish
        ''
          set -lx NIXPKGS_ALLOW_UNFREE 1
          nix build --impure --expr "with import <nixpkgs> {}; callPackage $argv[1] {}"
        '';
    };
    shellAbbrs = {
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
      tree = "${pkgs.tre-command}/bin/tre";
    };
    plugins = with pkgs.fishPlugins; [
      {
        name = "hydro";
        src = hydro;
      }
      {
        name = "fzf";
        src = fzf;
      }
    ];
  };
}
