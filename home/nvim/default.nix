{
  inputs,
  unstable,
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
              CATTESTVAR = "It worked!";
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
            ];
            startupPlugins.default = with unstable.vimPlugins; [
              catppuccin-nvim
              lz-n
              lzn-auto-require
              nvim-treesitter
              nvim-treesitter.withAllGrammars
              snacks-nvim
              # (pkgs.vimUtils.buildVimPlugin {
              #   name = "snacks-nvim";
              #   src = pkgs.fetchFromGitHub {
              #     owner = "folke";
              #     repo = "snacks.nvim";
              #     rev = "26d51af25109a38a1ae19d03df8b214e670f52b6"; # 2025-02-15
              #     hash = "sha256-ivd3rnYxR98Td97T7CSJ1PKVA/mkRIHFKHGmZp6vBdY=";
              #   };
              # })
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
