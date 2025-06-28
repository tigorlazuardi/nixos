{ ... }:
{
  imports = [
    ./telemetry

    ./adguard_home.nix
    ./anubis.nix
    ./authelia.nix
    ./caddy.nix
    ./cockpit.nix
    ./couchdb.nix
    ./db-gate.nix
    ./flaresolverr.nix
    ./forgejo.nix
    ./github-runner.nix
    ./homepage-dashboard.nix
    ./immich.nix
    ./jellyfin.nix
    ./kavita.nix
    ./mailcatcher.nix
    ./navidrome.nix
    ./nextcloud.nix
    ./nginx.nix
    ./ntfy-sh.nix
    ./openvpn.nix
    ./photoprism.nix
    ./postgres.nix
    ./redis.nix
    ./rust-motd.nix
    ./samba.nix
    ./stirling-pdf.nix
    ./stubby.nix
    ./syncthing.nix
    ./suwayomi.nix
    ./technitium.nix
    ./wireguard.nix

    ./ollama.nix
  ];
}
