{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  programs.zsh.plugins = lib.mkOrder 200 [
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
  ];
}
