{ pkgs, ... }:
{
  programs.bash = {
    enable = true;
    enableVteIntegration = true;
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
      tree = "${pkgs.tre-command}/bin/tre";
    };
    initExtra = # sh
      ''
        packfiles() {
          find $(NIXPKGS_ALLOW_UNFREE=1 nix build "nixpkgs#$1" --impure --no-link --print-out-paths) 
        }

        build() {
            nix build --impure --expr "with import <nixpkgs> {}; callPackage $1 {}"
        }
      '';
  };
}
