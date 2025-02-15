{
  inputs,
  unstable,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixCats.homeModule
  ];
  config = {
    nixCats =
      let
        cfgName = "nixvim";
      in
      {
        enable = true;
        nixpkgs_version = inputs.nixpkgs-unstable;
        packageNames = [ cfgName ];
        luaPath = "${./.}";
        categoryDefinitions.replace = (
          { ... }:
          {
            environmentVariables.default = {
            };
            lspsAndRuntimeDeps.default = with unstable; [
              fd
              ripgrep
              universal-ctags
            ];
            optionalPlugins.default = with unstable.vimPlugins; [
              nvim-treesitter-textobjects
              nvim-treesitter-endwise
              nvim-ts-autotag
              blink-cmp
              yanky-nvim
              (pkgs.vimUtils.buildVimPlugin {
                name = "trouble.nvim";
                src = inputs.trouble-nvim;
                version = inputs.trouble-nvim.shortRev;
              })
            ];
            startupPlugins.default = with unstable.vimPlugins; [
              catppuccin-nvim
              lz-n
              lzn-auto-require
              nvim-treesitter
              nvim-treesitter.withAllGrammars
              (pkgs.vimUtils.buildVimPlugin {
                name = "snacks.nvim";
                src = inputs.snacks-nvim;
                version = inputs.snacks-nvim.shortRev;
                nvimSkipModule = [
                  # Broke because it requires lazy.stats
                  "snacks.dashboard"
                ];
              })
            ];
          }
        );
        packageDefinitions.replace = {
          nixvim =
            { ... }:
            {
              settings = {
                wrapRc = true;
              };
              categories.default = true;
            };
        };
      };
  };
}
