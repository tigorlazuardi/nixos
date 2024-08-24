{ config, lib, pkgs, ... }:
let
  cfg = config.profile.programs.yazi;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      keymap = {
        manager.prepend_keymap = [
          {
            on = [ "m" ];
            run = "plugin bookmarks --args=save";
            desc = "Save current position as a bookmark";
          }
          {
            on = [ "'" ];
            run = "plugin bookmarks --args=jump";
            desc = "Jump to a bookmark";
          }
          {
            on = [ "b" "d" ];
            run = "plugin bookmarks --args=delete";
            desc = "Delete a bookmark";
          }
          {
            on = [ "b" "D" ];
            run = "plugin bookmarks --args=delete_all";
            desc = "Delete all bookmarks";
          }
        ];
      };
      settings = {
        manager = {
          # 1/8 width for parent, 4/8 width for current, 3/8 width for preview
          ratio = [ 1 4 3 ];
          sort_by = "natural";
          sort_sensitive = false;
          sort_dir_first = true;
          linemode = "permissions";
          show_hidden = true;
          show_symlink = true;
          scrolloff = 5;
        };
        opener = {
          edit = [
            { run = ''nvim "$@"''; block = true; desc = "Edit in Neovim"; }
          ];
          play = [
            { run = ''mpv "$@"''; orphan = true; desc = "Play in MPV"; }
          ];
          open = [
            { run = ''xdg-open "$@"''; desc = "Open"; }
          ];
        };
        open = {
          rules = [
            {
              mime = "text/*";
              use = "edit";
            }
            {
              mime = "video/*";
              use = "play";
            }
            {
              mime = "application/json";
              use = "edit";
            }
            # Multiple openers for a single rule
            {
              name = "*.html";
              use = [ "open" "edit" ];
            }
          ];
          append_rules = [
            { name = "*"; use = "open"; }
          ];
        };
      };
    };
    home.file = {
      ".config/yazi/plugins/boorkmarks.yazi" = {
        recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "dedukun";
          repo = "bookmarks.yazi";
          rev = "0.2.5";
          sha256 = "sha256-TSmZwy9jhf0D+6l4KbNQ6BjHbL0Vfo/yL3wt8bjo/EM=";
        };
      };
      ".config/yazi/init.lua".text = /*lua*/ ''
        require("bookmarks"):setup({
            last_directory = { enable = false, persist = false },
            persist = "none",
            desc_format = "full",
            notify = {
                enable = false,
                timeout = 1,
                message = {
                    new = "New bookmark '<key>' -> '<folder>'",
                    delete = "Deleted bookmark in '<key>'",
                    delete_all = "Deleted all bookmarks",
                },
            },
        })
      '';
    };
  };
}
