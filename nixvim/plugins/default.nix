{ pkgs, inputs, ... }:
{
  imports = [
    ./coding

    ./blink.nix
    ./fidget.nix
    ./git.nix
    ./mini.nix
    ./snacks.nix
    ./treesitter.nix
    ./ufo.nix
    ./yanky.nix
  ];

  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "lzn-auto-require";
        src = inputs.lzn-auto-require-nvim;
        version = inputs.lzn-auto-require-nvim.shortRev;
      })
    ];
    extraConfigLuaPost = # lua
      ''
        require('lzn-auto-require').enable()
      '';
    # Must be enabled for lazyLoading settings to work
    plugins.lz-n.enable = true;
  };
}
