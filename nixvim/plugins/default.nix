{ pkgs, inputs, ... }:
{
  imports = [
    ./snacks.nix
    ./blink.nix
    ./ufo.nix
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
    plugins = {
      # Core plugins.
      lz-n.enable = true;
      mini = {
        enable = true;
        lazyLoad.enable = true;
        lazyLoad.settings.ft = [ ];
        modules = {
          icons = { };
        };
      };
    };
  };
}
