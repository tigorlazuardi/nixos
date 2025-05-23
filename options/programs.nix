{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.profile = {
    discord = {
      enable = lib.mkEnableOption "discord";
      autostart = lib.mkEnableOption "discord autostart";
      window_rule = lib.mkOption {
        type = lib.types.str;
        default = "workspace 7 silent,class:(vesktop)";
      };
    };

    wine.enable = lib.mkEnableOption "wine";

    slack = {
      enable = lib.mkEnableOption "slack";
      autostart = lib.mkEnableOption "slack autostart";
      window_rule = lib.mkOption {
        type = lib.types.str;
        default = "workspace 6 silent,class:(Slack)";
      };
    };

    whatsapp = {
      enable = lib.mkEnableOption "whatsapp";
      autostart = lib.mkEnableOption "whatsapp autostart";
      window_rule = lib.mkOption {
        type = lib.types.str;
        default = "workspace 5 silent,class:(wasistlos)";
      };
    };

    syncthing.enable = lib.mkEnableOption "syncthing";

    obs.enable = lib.mkEnableOption "obs";

    neovide.enable = lib.mkEnableOption "neovide";
    ideavim.enable = lib.mkEnableOption "ideavim";
    kitty.enable = lib.mkEnableOption "kitty";

    mpris-proxy.enable = lib.mkEnableOption "mpris-proxy";

    variety = {
      enable = lib.mkEnableOption "variety";
      autostart = lib.mkEnableOption "variety autostart";
    };

    bitwarden = {
      enable = lib.mkEnableOption "bitwarden";
      autostart = lib.mkEnableOption "bitwarden autostart";
    };

    go.enable = lib.mkEnableOption "go";
    chromium.enable = lib.mkEnableOption "chromium";
    nnn.enable = lib.mkEnableOption "nnn";
    mpv.enable = lib.mkEnableOption "mpv";

    gh.enable = lib.mkEnableOption "gh"; # GitHub CLI
    spotify = {
      enable = lib.mkEnableOption "spotify";
      autostart = lib.mkEnableOption "spotify autostart";
      spotifyd.enable = lib.mkEnableOption "spotifyd";
    };
    firefox.enable = lib.mkEnableOption "firefox";
    vscode.enable = lib.mkEnableOption "vscode";

    # This is client jellyfin option only.
    # For server option, see podman.nix.
    jellyfin.enable = lib.mkEnableOption "jellyfin";
    dbeaver.enable = lib.mkEnableOption "dbeaver";

    microsoft-edge.enable = lib.mkEnableOption "microsoft-edge";
    nextcloud.enable = lib.mkEnableOption "nextcloud";

    cockpit.enable = lib.mkEnableOption "cockpit";
    home.programs = {
      cursor.enable = lib.mkEnableOption "cursor";
      dolphin.enable = lib.mkEnableOption "dolphin";
      rofi = {
        bookmarks = mkOption {
          type = types.listOf (
            types.submodule {
              options = {
                text = mkOption { type = types.str; };
                command = mkOption { type = types.str; };
              };
            }
          );
          default = [
            {
              text = "Youtube";
              command = "xdg-open 'https://www.youtube.com'";
            }
          ];
        };
      };
      bloomrpc.enable = lib.mkEnableOption "bloomrpc";
      zathura.enable = lib.mkEnableOption "zathura";
      floorp.enable = lib.mkEnableOption "floorp";
      java.enable = lib.mkEnableOption "java";
      krita.enable = lib.mkEnableOption "krita";
      ghostty.enable = lib.mkEnableOption "ghostty";
      nemo.enable = lib.mkEnableOption "nemo";
      zellij = {
        enable = lib.mkEnableOption "zellij";

        # Wether to enable auto attach to zellij sessions.
        #
        # Best used for servers when you want to auto attach to a session when ssh
        # into a server.
        #
        # Desktop usage is not recommended since uses typically have multiple
        # terminal windows open and it can be confusing to have a terminal
        # window auto attach to a zellij session.
        #
        # Also, there is resurrections features that zellij offers.
        # So desktop user can just resurrect the session if they want to.
        autoAttach = lib.mkEnableOption "zellij autoAttach";
        mod = lib.mkOption {
          type = lib.types.str;
          default = "Ctrl a";
          description = "Mod key to use for zellij to enter tmux mode and exits locked mode.";
        };
        zjstatus = {
          theme = lib.mkOption {
            type = lib.types.path;
            default = ../home/programs/zellij/themes/zjstatus/catppuccin-mocha.nix;
            description = "Default zellij status theme";
          };
          timezone = lib.mkOption {
            type = lib.types.str;
            default = "Asia/Jakarta";
            description = "Timezone to use for zellij status";
          };
        };
      };
      foot = {
        enable = lib.mkEnableOption "foot";
        font = lib.mkOption {
          type = lib.types.str;
          default = "Hack Nerd Font Mono:size=12";
        };
      };
      bruno.enable = lib.mkEnableOption "bruno";
      zoom.enable = lib.mkEnableOption "zoom";
      elisa.enable = lib.mkEnableOption "elisa";
      obsidian.enable = lib.mkEnableOption "obsidian";
      jetbrains.idea.enable = lib.mkEnableOption "jetbrains.idea";
      neocal.enable = lib.mkEnableOption "neocal";
    };

    programs = {
      mongodb-compass.enable = lib.mkEnableOption "mongodb-compass";
      yazi.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      easyeffects.enable = lib.mkEnableOption "easyeffects";
      wezterm.enable = lib.mkEnableOption "wezterm";
      wezterm.config.window_background_opacity = lib.mkOption {
        type = lib.types.float;
        default = 0.8;
      };
    };
  };
}
