{ ... }:
{
  imports = [
    ./telemetry

    ./caddy.nix
    ./cockpit.nix
    ./forgejo.nix
    ./jellyfin.nix
    ./kavita.nix
    ./navidrome.nix
    ./nextcloud.nix
    ./openvpn.nix
    ./rust-motd.nix
    ./samba.nix
    ./stubby.nix
    ./syncthing.nix
    ./wireguard.nix
    ./photoprism.nix
  ];
}
