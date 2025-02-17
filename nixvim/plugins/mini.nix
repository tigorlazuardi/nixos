{ unstable, ... }:
{
  programs.nixvim.keymaps = [
    {
      action = "<cmd>lua if not MiniFiles.close() then MiniFiles.open() end<cr>";
      key = "-";
      mode = "n";
      options.desc = "(Mini) Open Files";
    }
  ];
  programs.nixvim.plugins.mini = {
    enable = true;
    package = unstable.vimPlugins.mini-nvim;
    mockDevIcons = true;
    modules = {
      icons = { };
      pairs = { };
      comment = { };
      files = { };
      diff = {
        view = {
          style = "sign";
        };
      };
      surround = {
        mappings = {
          add = "gsa";
          delete = "gsd";
          find = "gsf";
          find_left = "gsF";
          highlight = "gsh";
          replace = "gsr";
          update_n_lines = "gsn";
        };
      };
      starter = {
        content_hooks = {
          "__unkeyed-1.adding_bullet" = {
            __raw = "require('mini.starter').gen_hook.adding_bullet()";
          };
          "__unkeyed-2.indexing" = {
            __raw = ''require('mini.starter').gen_hook.indexing('all', { 'Builtin actions', 'Sessions', 'Actions' })'';
          };
          "__unkeyed-3.padding" = {
            __raw = "require('mini.starter').gen_hook.aligning('center', 'center')";
          };
        };
        evaluate_single = true;
        header = ''
          ███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗
          ████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║
          ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║
          ██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║
          ██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║
        '';
        items = {
          "__unkeyed-1.sessions" = [
            {
              name = "S. Load Session";
              action = "lua require('persistence').load()";
              section = "Sessions";
            }
            {
              name = "L. Select Sessions";
              action = "lua require('persistence').select()";
              section = "Sessions";
            }
          ];
          "__unkeyed-2.actions" = [
            {
              name = "F. Find Files";
              action = "lua Snacks.picker.files()";
              section = "Actions";
            }
            {
              name = "G. Find Text";
              action = "lua Snacks.picker.grep()";
              section = "Actions";
            }
          ];
          "__unkeyed-3.builtin_actions" = {
            __raw = "require('mini.starter').sections.builtin_actions()";
          };
          "__unkeyed-4.recent_files_current_directory" = {
            __raw = "require('mini.starter').sections.recent_files(10, true)";
          };
        };
      };
    };
  };
}
