{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.home.environments.protobuf;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      buf
      protoc-gen-go
      protoc-gen-go-grpc
      protoc-gen-js
      protoc-gen-connect-go
    ];
  };
}
