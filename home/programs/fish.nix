{ pkgs, ... }:
{

  home.packages = with pkgs; [ grc ];
  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = "";
      packfiles = # fish
        ''
          begin
            set -lx NIXPKGS_ALLOW_UNFREE 1
            nix build "nixpkgs#$argv[1]" --impure --no-link --print-out-paths
          end
        '';
      build = # fish
        ''
          begin
            set -lx NIXPKGS_ALLOW_UNFREE 1
            nix build --impure --expr "with import <nixpkgs> {}; callPackage $argv[1] {}"
          end
        '';
    };
    shellAliases = {
      ls = "${pkgs.eza}/bin/eza -lah";
      cat = "${pkgs.bat}/bin/bat";
      lg = "${pkgs.lazygit}/bin/lazygit";
      g = "${pkgs.lazygit}/bin/lazygit";
      du = "${pkgs.dust}/bin/dust";
      jq = "${pkgs.gojq}/bin/gojq";
      v = "nvim";
      cd = "z";
      tree = "${pkgs.tre-command}/bin/tre";
    };
    shellAbbrs = {
      update = "nh os switch -- --accept-flake-config";
      superupdate = "nh os switch --update -- --accept-flake-config";
      uptest = "nh os test -- --accept-flake-config";
      dry = "sudo nixos-rebuild dry-activate --flake $HOME/dotfiles";
    };
    interactiveShellInit = # fish
      ''
        set --universal hydro_multiline true
      '';
    plugins = with pkgs.fishPlugins; [
      {
        name = "hydro";
        src = hydro.src;
      }
      {
        name = "grc";
        src = grc.src;
      }
      {
        name = "fzf";
        src = fzf.src;
      }
    ];
  };
}
