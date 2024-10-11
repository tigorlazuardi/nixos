{ ... }:
{
  imports = [
    ./real-debrid-manager.nix
    ./qbittorrent.nix
    ./sonarr.nix
    ./prowlarr.nix
    ./bazarr.nix
    ./radarr.nix
    ./rdtclient.nix
    ./recyclarr.nix
  ];

  profile.services.ntfy-sh.client.settings.subscribe = [
    {
      topic = "servarr";
    }
  ];
}
