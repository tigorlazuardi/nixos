{ config, lib, ... }:
let
  cfg = config.profile.services.suwayomi;
  inherit (lib) mkIf mkForce;
  domain = "manga.tigor.web.id";
in
{
  config = mkIf cfg.enable {
    profile.services.flaresolverr.enable = mkForce true;

    users.users.suwayomi.extraGroups = [
      config.profile.user.name
    ];

    users.users.${config.profile.user.name}.extraGroups = [
      "suwayomi"
    ];

    fileSystems."${config.services.suwayomi-server.dataDir}" = {
      device = "/nas/services/suwayomi-server";
      fsType = "none";
      options = [ "bind" ];
    };

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations."/" =
        let
          server = config.services.suwayomi-server.settings.server;
        in
        {
          proxyPass = "http://${server.ip}:${toString server.port}";
          proxyWebsockets = true;
        };
    };

    services.suwayomi-server = {
      enable = true;
      settings = {
        server = {
          ip = "0.0.0.0";
          port = 4567;
          initialOpenInBrowserEnabled = false;
          webUIEnabled = true;
          webUIInterface = "browser";
          webUIFlavor = "WebUI";

          # Downloader
          downloadAsCbz = true;
          autoDownloadNewChapters = true;
          excludeEntryWithUnreadChapters = false;
          autoDownloadNewChaptersLimit = 0;

          # Requests
          maxSourcesInParallel = 20;

          # Extension Repo
          extensionRepos = [
            "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
          ];

          # Updates
          excludeUnreadChapters = false;
          excludeNotStarted = false;
          excludeCompleted = true;
          globalUpdateInterval = 6; # Hours. 6 minimum.
          updateMangas = true;

          flareSolverrEnabled = true;
          flareSolverrUrl = "https://${config.profile.services.flaresolverr.domain}";
          flareSolverrTimeout = 60; # seconds.
          flareSolverrSessionName = "suwayomi";
          flareSolverrSessionTtl = 15; # minutes.
        };
      };
    };
  };
}
