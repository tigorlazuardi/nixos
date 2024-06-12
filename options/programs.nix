{ lib, ... }:
{
  options.profile = {
    discord = {
      enable = lib.mkEnableOption "discord";
      autostart = lib.mkEnableOption "discord autostart";
      window_rule = lib.mkOption {
        type = lib.types.str;
        default = "workspace 7 silent,class:(discord)";
      };
    };

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
        default = "workspace 5 silent,class:(whatsapp-for-linux)";
      };
    };

    syncthing.enable = lib.mkEnableOption "syncthing";

    obs.enable = lib.mkEnableOption "obs";

    wezterm.enable = lib.mkEnableOption "wezterm";
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
    };
    firefox.enable = lib.mkEnableOption "firefox";
    vscode.enable = lib.mkEnableOption "vscode";

    # This is client jellyfin option only.
    # For server option, see podman.nix.
    jellyfin.enable = lib.mkEnableOption "jellyfin";
    dbeaver.enable = lib.mkEnableOption "dbeaver";

    microsoft-edge.enable = lib.mkEnableOption "microsoft-edge";
    nextcloud.enable = lib.mkEnableOption "nextcloud";
  };
}
