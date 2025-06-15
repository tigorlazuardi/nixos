{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;
  socketActivationType = types.submodule (
    { config, ... }:
    {
      options.socketActivation = {
        enable = mkEnableOption "socket activation";
        host = mkOption { type = types.str; };
        port = mkOption { type = types.ints.u16; };
        socketAddress = mkOption {
          type = types.str;
          default = "/run/socket-activation.${config.name}.sock";
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
            default = "${pkgs.waitport}/bin/waitport ${config.socketActivation.host} ${toString config.socketActivation.port}";
            description = "The command to use to wait for the service to be ready. This can be used to customize the waiting behavior, e.g. to use a different tool or command.";
          };
        };
      };
      # config = mkIf config.enable {
      #   unitConfig.StopWhenUnneeded = mkIf config.socketActivation.stopWhenUnneeded true; # Only shows in the .service file if enabled
      #   serviceConfig.ExecStartPost = mkIf config.wait.enable [
      #     config.socketActivation.wait.command
      #   ];
      # };
    }
  );
  socketActivatedServices = lib.filterAttrs (
    _: conf: conf.socketActivation.enable
  ) config.systemd.services;
  names = lib.attrsets.mapAttrsToList (name: _: name) socketActivatedServices;
  proxyNames = lib.attrsets.mapAttrsToList (name: _: "${name}-proxy") socketActivatedServices;
in
{
  options.systemd.services = mkOption {
    type = types.attrsOf socketActivationType;
  };
  config = {
    systemd.services =
      lib.attrsets.genAttrs proxyNames (
        proxyName:
        (
          let
            name = lib.strings.removeSuffix "-proxy" proxyName;
            cfg = config.systemd.services.${name}.socketActivation;
          in
          {
            unitConfig = {
              Requires = [
                "${name}.service"
                "${proxyName}.socket"
              ];
              After = [
                "${name}.service"
                "${proxyName}.socket"
              ];
            };
            serviceConfig.ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=${cfg.idleTimeout} ${cfg.host}:${toString cfg.port}";
          }
        )
      )
      // lib.attrsets.getAttrs names (name: {
        serviceConfig = {
          ExecStartPost = mkIf config.systemd.services.${name}.socketActivation.wait.enable [
            config.systemd.services.${name}.socketActivation.wait.command
          ];
        };
        unitConfig = {
          StopWhenUnneeded = mkIf config.systemd.services.${name}.socketActivation.stopWhenUnneeded true;
        };
      });
    systemd.sockets = lib.attrsets.genAttrs proxyNames (
      proxyName:
      (
        let
          name = lib.strings.removeSuffix "-proxy" proxyName;
          cfg = config.systemd.services.${name}.socketActivation;
        in
        {
          listenStreams = [ cfg.socketAddress ];
          wantedBy = [ "sockets.target" ];
        }
      )
    );
  };
}
