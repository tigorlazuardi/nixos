{
  inputs,
  ...
}:
{
  imports = [
    inputs.nixCats.homeModule
  ];
  config = {
    nixCats = {
      enable = true;
      nixpkgs_version = inputs.nixpkgs;
      packageNames = [ "nixvim" ];
      luaPath = "${./.}";
      categoryDefinitions.replace = (
        { pkgs, ... }:
        {
          environmentVariables.default = {
            CATTESTVAR = "It worked!";
          };
          startupPlugins.default = with pkgs.vimPlugins; [
            catppuccin-nvim
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
