{ ... }:
let
  primaryMonitor = "AOC U34G3G3R3 QXVP2JA000099";
  secondaryMonitor = "ViewSonic Corporation VX3276-QHD V9W204243765";
in
{
  imports = [
    ../options
  ];

  profile = {
    hostname = "castle";
    user = {
      name = "tigor";
      fullName = "Tigor Hutasuhut";
    };

    hyprland = {
      enable = true;
      settings = {
        monitors = [
          "desc:${primaryMonitor},3440x1440@165,0x0,1"
          "desc:${secondaryMonitor},2560x1440@75,440x-1440,1"
        ];
        workspaces = [
          "1, monitor:desc:${primaryMonitor}, default:true"
          "2, monitor:desc:${primaryMonitor}"
          "3, monitor:desc:${primaryMonitor}"
          "4, monitor:desc:${primaryMonitor}"
          "5, monitor:desc:${primaryMonitor}"
          "6, monitor:desc:${primaryMonitor}"
          "7, monitor:desc:${primaryMonitor}"
          "8, monitor:desc:${secondaryMonitor}, default:true"
          "9, monitor:desc:${secondaryMonitor}"
          "10, monitor:desc:${secondaryMonitor}"
        ];
      };
      waybar.persistent-workspaces = {
        DP-1 = [ 1 2 3 4 5 6 7 ];
        DP-2 = [ 8 9 10 ];
      };
      pyprland.wallpaper-dirs = [ "/nas/redmage/images/windows" ];
      wallust.alpha = 80;
      swayosd.display = "DP-1";
      dunst.monitor = "1";
    };
    discord.enable = true;
    slack.enable = true;
    whatsapp.enable = true;
    obs.enable = true;
    avahi.enable = true;
    steam.enable = true;
    scanner.enable = true;
    vial.enable = true;
    printing.enable = true;

    firefox.enable = true;

    security.sudo.wheelNeedsPassword = false;

    keyboard.language.japanese = true;

    system.stateVersion = "23.11";

    mpris-proxy.enable = true;
    kitty.enable = true;
    neovide.enable = true;
    spotify.enable = true;
    vscode.enable = true;
    jellyfin.enable = true;
    mpv.enable = true;
    go.enable = true;
    chromium.enable = true;
    bitwarden.enable = true;
    dbeaver.enable = true;
    kde.enable = false;

    microsoft-edge.enable = true;
    nextcloud.enable = false;

    home.programs = {
      zathura.enable = true;
    };
    programs.easyeffects.enable = true;
    programs.wezterm.enable = true;
  };
}
