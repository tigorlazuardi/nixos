{ unstable, ... }:
{
  # programs.nixvim = {
  #   extraPlugins = [
  #     {
  #       plugin = unstable.vimPlugins.neo-tree-nvim;
  #       optional = true;
  #     }
  #   ];
  #   extraConfigLua = ''
  #     vim.api.nvim_create_autocmd("BufEnter", {
  #       group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
  #       desc = "Start Neo-tree with directory",
  #       once = true,
  #       callback = function()
  #         if package.loaded["neo-tree"] then
  #           return
  #         else
  #           local stats = vim.uv.fs_stat(vim.fn.argv(0))
  #           if stats and stats.type == "directory" then
  #             require("neo-tree")
  #           end
  #         end
  #       end,
  #     })
  #
  #     require('lz.n').load({
  #       'neo-tree.nvim';
  #       cmd = "Neotree";
  #       keys = {
  #         {
  #           "<leader>e",
  #           function()
  #             require("neo-tree.command").execute({ toggle = true })
  #           end,
  #           desc = "Explorer NeoTree (Root Dir)",
  #         },
  #         {
  #           "<leader>be",
  #           function()
  #             require("neo-tree.command").execute({ source = "buffers", toggle = true })
  #           end,
  #           desc = "Buffer Explorer",
  #         },
  #       },
  #       after = function()
  #         local function on_move(data)
  #           Snacks.rename.on_rename_file(data.source, data.destination)
  #         end
  #
  #         local events = require("neo-tree.events")
  #         opts.event_handlers = opts.event_handlers or {}
  #         vim.list_extend(opts.event_handlers, {
  #           { event = events.FILE_MOVED, handler = on_move },
  #           { event = events.FILE_RENAMED, handler = on_move },
  #         })
  #         --------------------------------------
  #         require("neo-tree").setup({
  #           sources = { "filesystem", "buffers", "git_status" },
  #           open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
  #           filesystem = {
  #             bind_to_cwd = false,
  #             follow_current_file = { enabled = true },
  #             use_libuv_file_watcher = true,
  #           },
  #           window = {
  #             mappings = {
  #               ["l"] = "open",
  #               ["h"] = "close_node",
  #               ["<space>"] = "none",
  #               ["Y"] = {
  #                 function(state)
  #                   local node = state.tree:get_node()
  #                   local path = node:get_id()
  #                   vim.fn.setreg("+", path, "c")
  #                 end,
  #                 desc = "Copy Path to Clipboard",
  #               },
  #               ["P"] = { "toggle_preview", config = { use_float = false } },
  #             },
  #           },
  #           default_component_configs = {
  #             indent = {
  #               with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
  #               expander_collapsed = "",
  #               expander_expanded = "",
  #               expander_highlight = "NeoTreeExpander",
  #             },
  #             git_status = {
  #               symbols = {
  #                 unstaged = "󰄱",
  #                 staged = "󰱒",
  #               },
  #             },
  #           },
  #         })
  #         --------------------------------------
  #         vim.api.nvim_create_autocmd("TermClose", {
  #           pattern = "*lazygit",
  #           callback = function()
  #             if package.loaded["neo-tree.sources.git_status"] then
  #               require("neo-tree.sources.git_status").refresh()
  #             end
  #           end,
  #         })
  #       end,
  #     })
  #   '';
  # };
}
