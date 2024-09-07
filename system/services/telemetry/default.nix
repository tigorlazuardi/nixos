{ ... }:
{
  imports = [
    ./grafana.nix
    ./loki.nix
    ./tempo.nix
    ./alloy.nix
    ./mimir.nix
  ];
}
