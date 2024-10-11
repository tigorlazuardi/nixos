{ ... }:
{
  imports = [
    ./grafana.nix
    ./loki.nix
    ./tempo.nix
    ./alloy.nix
    ./mimir.nix
    ./prometheus.nix
  ];

  profile.services.ntfy-sh.client.settings.subscribe = [
    { topic = "homeserver"; }
    { topic = "grafana"; }
  ];
}
