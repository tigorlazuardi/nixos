{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  cfg = config.profile.programs.yazi;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      package = unstable.yazi;
      initLua =
        # lua
        ''
          require("bookmarks"):setup({
          	last_directory = { enable = true, persist = true, mode = "dir" },
          	persist = "all",
          	desc_format = "full",
          	file_pick_mode = "hover",
          	custom_desc_input = false,
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
      enableZshIntegration = true;
      keymap = {
        manager = {
          prepend_keymap = [
            {
              on = [ "m" ];
              run = "plugin bookmarks save";
              desc = "Save current position as a bookmark";
            }
            {
              on = [ "'" ];
              run = "plugin bookmarks jump";
              desc = "Jump to a bookmark";
            }
            {
              on = [
                "b"
                "d"
              ];
              run = "plugin bookmarks delete";
              desc = "Delete a bookmark";
            }
            {
              on = [
                "b"
                "D"
              ];
              run = "plugin bookmarks delete_all";
              desc = "Delete all bookmarks";
            }
          ];
        };
      };
      settings = {
        manager = {
          # 1/8 width for parent, 4/8 width for current, 3/8 width for preview
          ratio = [
            1
            4
            3
          ];
          sort_by = "natural";
          sort_sensitive = false;
          sort_dir_first = true;
          linemode = "size";
          show_hidden = true;
          show_symlink = true;
          scrolloff = 5;
        };
        opener = {
          edit = [
            {
              run = ''nvim "$@"'';
              block = true;
              desc = "Edit in Neovim";
            }
          ];
          play = [
            {
              run = ''mpv "$@"'';
              orphan = true;
              desc = "Play in MPV";
            }
          ];
          open = [
            {
              run = ''xdg-open "$@"'';
              desc = "Open";
            }
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
              use = [
                "open"
                "edit"
              ];
            }
          ];
          append_rules = [
            {
              name = "*";
              use = "open";
            }
          ];
        };
        plugin = {
          prepend_previewers = [
            {
              mime = "{image,audio,video}/*";
              run = "mediainfo";
            }
            {
              mime = "application/x-subrip";
              run = "mediainfo";
            }
          ];
        };
      };
    };
    home.file = {
      ".config/yazi/plugins/bookmarks.yazi" = {
        recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "dedukun";
          repo = "bookmarks.yazi";
          rev = "95b2c586f4a40da8b6a079ec9256058ad0292e47";
          sha256 = "sha256-cNgcTa8s+tTqAvF10fmd+o5PBludiidRua/dXArquZI=";
        };
      };
      ".config/yazi/plugins/mediainfo.yazi" = {
        recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "boydaihungst";
          repo = "mediainfo.yazi";
          rev = "447fe95239a488459cfdbd12f3293d91ac6ae0d7";
          hash = "sha256-U6rr3TrFTtnibrwJdJ4rN2Xco4Bt4QbwEVUTNXlWRps=";
        };
      };
    };
  };
}
