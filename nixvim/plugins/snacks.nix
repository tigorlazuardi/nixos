{
  inputs,
  pkgs,
  ...
}:
{
  programs.nixvim.plugins.snacks = {
    enable = true;
    settings = {
      bigfile = {
        enabled = true;
      };
      dashboard = {
        enabled = true;
      };
      explorer = {
        enabled = true;
      };
      indent = {
        enabled = true;
      };
      input = {
        enabled = true;
      };
      picker = {
        enabled = true;
      };
      notifier = {
        enabled = true;
      };
      quickfile = {
        enabled = true;
      };
      scope = {
        enabled = true;
      };
      scroll = {
        enabled = true;
      };
      statuscolumn = {
        enabled = true;
      };
      words = {
        enabled = true;
      };
    };
    package = pkgs.vimUtils.buildVimPlugin {
      pname = "snacks-nvim";
      src = inputs.snacks-nvim;
      version = inputs.snacks-nvim.shortRev;
      dependencies = [
        (pkgs.vimUtils.buildVimPlugin {
          pname = "trouble-nvim";
          src = inputs.trouble-nvim;
          version = inputs.trouble-nvim.shortRev;
        })
      ];
    };
  };
}
