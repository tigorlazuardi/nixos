{ pkgs, ... }:
{
  home.packages = with pkgs.nodePackages_latest; [
    nodejs
    pnpm
    prettier
  ];
}
