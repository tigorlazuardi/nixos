{
  config,
  lib,
  pkgs,
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
      enableZshIntegration = true;
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
      ".config/yazi/plugins/boorkmarks.yazi" = {
        recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "dedukun";
          repo = "bookmarks.yazi";
          rev = "0.2.5";
          sha256 = "sha256-TSmZwy9jhf0D+6l4KbNQ6BjHbL0Vfo/yL3wt8bjo/EM=";
        };
      };
      ".config/yazi/plugins/mediainfo.yazi" = {
        recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "Ape";
          repo = "mediainfo.yazi";
          rev = "c69314e80f5b45fe87a0e06a10d064ed54110439";
          hash = "sha256-8xdBPdKSiwB7iRU8DJdTHY+BjfR9D3FtyVtDL9tNiy4=";
        };
      };
    };
  };
}
