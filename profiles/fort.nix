{ ... }:
{
  imports = [ ../options ];

  profile = {
    environment = {
      bareksa.enable = true;
    };

    hostname = "fort";
    user = {
      name = "tigor";
      fullName = "Tigor Hutasuhut";
    };
    system.stateVersion = "23.11";

    hyprland = {
      enable = true;
      settings = {
        monitors = [ ",preferred,auto,1" ];
        workspaces = [
          "1,default:true"
          "2"
          "3"
          "4"
          "5"
          "6"
          "7"
          "8"
          "9"
          "10"
        ];
      };
      waybar.persistent-workspaces = {
        eDP-1 = [
          1
          2
          3
          4
          5
          6
          7
          8
          9
          10
        ];
      };
      pyprland.wallpaper-dirs = [ "/home/tigor/Syncthing/Redmage/Laptop-Kerja" ];
    };
    discord = {
      enable = true;
      autostart = true;
    };
    slack = {
      enable = true;
      autostart = true;
    };
    whatsapp.enable = true;
    syncthing.enable = true;
    bluetooth.enable = true;

    firefox.enable = true;

    brightnessctl.enable = true;
    keyboard.language.japanese = true;

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

    microsoft-edge.enable = false;
    nextcloud.enable = false;

    programs.easyeffects.enable = true;
    steam.enable = true;
    programs.wezterm.enable = true;
    programs.mongodb-compass.enable = true;

    podman.enable = true;

    home.programs = {
      foot.enable = true;
      foot.font = "Hack Nerd Font Mono:size=8";
      zellij.enable = false;
      bruno.enable = true;
      elisa.enable = true;
      obsidian.enable = true;
      zoom.enable = true;
    };

    home.environments = {
      protobuf.enable = true;
    };

    games.minecraft.enable = true;

    flatpak = {
      enable = true;
      zen-browser.enable = false;
      redisinsight.enable = true;
    };

    services.ntfy-sh.client.enable = true;
    services.resolved.enable = true;
  };
}
