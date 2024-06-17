{ ... }:
{
  imports = [
    ./caddy.nix
    ./cockpit.nix
    ./forgejo.nix
    ./samba.nix
    ./nextcloud.nix
    ./syncthing.nix
    ./kavita.nix
    ./openvpn.nix
    ./stubby.nix
    ./jellyfin.nix
  ];
}
