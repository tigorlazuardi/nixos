{ lib, ... }:
{
  programs.nixvim = rec {
    autoCmd = [
      {
        event = [
          "FocusGained"
          "TermClose"
          "TermLeave"
        ];
        group = "XCheckTime";
        callback.__raw = ''
          function()
            if vim.o.buftype ~= "nofile" then
              vim.cmd("checktime")
            end
          end
        '';
        desc = "Check if we need to reload the file when it changed";
      }
      {
        event = [ "VimResized" ];
        group = "XResizeSplits";
        callback.__raw = ''
          function()
            local current_tab = vim.fn.tabpagenr()
            vim.cmd("tabdo wincmd =")
            vim.cmd("tabnext " .. current_tab)
          end
        '';
        desc = "resize splits if window got resized";
      }
      {
        event = [ "BufReadPost" ];
        group = "XLastLoc";
        callback.__raw = ''
          function(event)
            local exclude = { "gitcommit" }
            local buf = event.buf
            if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].x_last_loc then
              return
            end
            vim.b[buf].x_last_loc = true
            local mark = vim.api.nvim_buf_get_mark(buf, '"')
            local lcount = vim.api.nvim_buf_line_count(buf)
            if mark[1] > 0 and mark[1] <= lcount then
              pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
          end
        '';
        desc = "go to last loc when opening a buffer";
      }
      # close some filetypes with <q>
      {
        event = [ "FileType" ];
        pattern = [
          "PlenaryTestPopup"
          "checkhealth"
          "dbout"
          "gitsigns-blame"
          "grug-far"
          "help"
          "lspinfo"
          "neotest-output"
          "neotest-output-panel"
          "neotest-summary"
          "notify"
          "qf"
          "spectre_panel"
          "startuptime"
          "tsplayground"
          "fugitive"
        ];
        group = "XCloseWithQ";
        callback.__raw = ''
          function(event)
            vim.bo[event.buf].buflisted = false
            vim.schedule(function()
              vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
              end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
              })
            end)
          end
        '';
        desc = "close some filetypes with <q>";
      }
      {
        event = [ "FileType" ];
        pattern = [ "man" ];
        group = "XManUnlisted";
        callback.__raw = ''
          function(event)
            vim.bo[event.buf].buflisted = false
          end  
        '';
        desc = "Force man pages to be unlisted in buffer list";
      }
      {
        event = [ "FileType" ];
        pattern = [
          "json"
          "jsonc"
          "json5"
        ];
        callback.__raw = ''
          function()
            vim.opt_local.conceallevel = 0 
          end
        '';
        group = "XJsonConceal";
        desc = "Fix JSON Coneal Level";
      }
      {
        event = [ "BufWritePre" ];
        group = "XAutoCreateDirs";
        callback.__raw = ''
          function(event)
            if event.match:match("^%w%w+:[\\/][\\/]") then
              return
            end
            local file = vim.uv.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
          end
        '';
        desc = "Create intermediate directories before writing a file if they don't exist";
      }
    ];
    autoGroups =
      let
        groupsToCreate = (map (auto: auto.group) (builtins.filter (auto: auto.group != null) autoCmd));
      in
      lib.genAttrs groupsToCreate (_: {
        clear = true;
      });
  };
}
