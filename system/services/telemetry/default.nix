{ ... }:
{
  imports = [
    ./grafana.nix
    ./loki.nix
    ./tempo.nix
  ];
}
