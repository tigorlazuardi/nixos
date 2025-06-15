{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    ;
  socketActivationType = types.submodule (
    { name, ... }:
    let
      cfg = config.systemd.socketActivations."${name}";
    in
    {
      options = {
        name = mkOption {
          type = types.str;
          default = name;
        };
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable socket activation for this service. This will create a systemd socket unit that listens on the specified host and port, and starts the service when a connection is made.";
        };
        host = mkOption { type = types.str; };
        port = mkOption { type = types.ints.u16; };
        socketAddress = mkOption {
          type = types.str;
          default = "/run/socket-activation.${cfg.name}.sock";
          description = "The socket address for the socket activation service. Simple string so other services can use this config option directly, e.g. nginx reverse proxy";
        };
        stopWhenUnneeded = mkOption {
          type = types.bool;
          default = true;
          description = "Stop the service when the connection is idle for a certain time";
        };
        idleTimeout = mkOption {
          type = types.str;
          default = "5m";
          description = "The time after which the service is stopped when no connections are made. This is only effective if `stopWhenUnneeded` is enabled.";
        };
        wait = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "wait tells systemd to buffer the connection until the service is ready to accept it. Has a deadline of 1 minute.";
          };
          command = mkOption {
            type = types.str;
            default = "${pkgs.waitport}/bin/waitport ${cfg.host} ${toString cfg.port}";
            description = "The command to use to wait for the service to be ready. This can be used to customize the waiting behavior, e.g. to use a different tool or command.";
          };
        };
      };
    }
  );
  socketActivatedServices = lib.filterAttrs (_: conf: conf.enable) config.systemd.socketActivations;
  names = lib.attrsets.mapAttrsToList (name: _: name) socketActivatedServices;
in
{
  options.systemd.socketActivations = mkOption {
    type = types.lazyAttrsOf socketActivationType;
    default = { };
  };
  config = {
    systemd.services =
      builtins.listToAttrs (
        map (
          name:
          let
            cfg = config.systemd.socketActivations."${name}";
          in
          {
            inherit name;
            value = {
              unitConfig.StopWhenUnneeded = mkIf cfg.stopWhenUnneeded true;
              serviceConfig.ExecStartPost = mkIf cfg.wait.enable [
                cfg.wait.command
              ];
              wantedBy = lib.mkForce [ ];
            };
          }
        ) names
      )
      // builtins.listToAttrs (
        map (
          name:
          let
            cfg = config.systemd.socketActivations."${name}";
            proxy = "${name}-proxy";
          in
          {
            name = proxy;
            value = {
              unitConfig = {
                Requires = [
                  "${name}.service"
                  "${proxy}.socket"
                ];
                After = [
                  "${name}.service"
                  "${proxy}.socket"
                ];
              };
              serviceConfig.ExecStart = ''${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=${cfg.idleTimeout} ${cfg.host}:${toString cfg.port}'';
            };
          }
        ) names
      );
    systemd.sockets = builtins.listToAttrs (
      map (
        name:
        let
          cfg = config.systemd.socketActivations."${name}";
          proxy = "${name}-proxy";
        in
        {
          name = proxy;
          value = {
            listenStreams = [ cfg.socketAddress ];
            wantedBy = [ "sockets.target" ];
          };
        }
      ) names
    );
  };
}
