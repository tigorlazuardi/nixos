{ ... }:
{
  imports = [
    ./telemetry

    ./caddy.nix
    ./cockpit.nix
    ./couchdb.nix
    ./flaresolverr.nix
    ./forgejo.nix
    ./jellyfin.nix
    ./kavita.nix
    ./navidrome.nix
    ./nextcloud.nix
    ./nginx.nix
    ./ntfy-sh.nix
    ./openvpn.nix
    ./photoprism.nix
    ./rust-motd.nix
    ./samba.nix
    ./stubby.nix
    ./syncthing.nix
    ./suwayomi.nix
    ./technitium.nix
    ./wireguard.nix
  ];
}
