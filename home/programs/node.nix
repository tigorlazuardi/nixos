{ pkgs, config, ... }:
{
  home.packages = with pkgs.nodePackages_latest; [
    nodejs
    pnpm
    prettier
  ];

  home.sessionPath = [ "${config.home.homeDirectory}/.local/npm/bin" ];

  home.file.".npmrc".text =
    # ini
    ''
      prefix=${config.home.homeDirectory}/.local/npm
    '';

  programs.zsh.plugins = [
    {
      name = "zsh-better-npm-completion";
      src = pkgs.zsh-better-npm-completion;
      file = "share/zsh-better-npm-completion";
    }
  ];
}
