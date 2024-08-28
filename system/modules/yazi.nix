{ config, lib, pkgs, ... }:
let
  cfg = config.profile.programs.yazi;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mediainfo
      ffmpegthumbnailer
    ];
    programs.yazi = {
      enable = true;
      settings = {
        # https://yazi-rs.github.io/docs/configuration/yazi
        yazi = {
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
    };
  };
}
