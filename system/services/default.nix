{ ... }:
{
  imports = [
    ./telemetry

    ./caddy.nix
    ./cockpit.nix
    ./couchdb.nix
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
    ./technitium.nix
    ./wireguard.nix
  ];
}
