{ pkgs, config, lib, ... }:
let
  cfg = config.profile.kde;
in
{
  config = lib.mkIf cfg.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    services.xserver.desktopManager.plasma5.enable = true;
    services.xserver.displayManager = {
      sddm.enable = true;
      defaultSession = "plasmawayland";
    };

    environment.systemPackages = with pkgs; [
      catppuccin-kde
      catppuccin-cursors
      catppuccin-sddm-corners
      plasma-browser-integration
      kwin-dynamic-workspaces
      libsForQt5.bismuth
      haruna
    ];

    environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source =
      "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";

    # Configure keymap in X11
    services.xserver = {
      layout = "us";
      xkbVariant = "";
    };

    programs.kdeconnect.enable = true;
  };
}
