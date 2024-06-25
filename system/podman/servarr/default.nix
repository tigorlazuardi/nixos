{ ... }:
{
  imports = [
    # ./real-debrid-manager.nix
    ./qbittorrent.nix
    ./sonarr.nix
    ./prowlarr.nix
    ./bazarr.nix
  ];
}
