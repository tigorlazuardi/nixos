{ config, lib, ... }:
let
  cfg = config.profile.services.samba;
  user = config.profile.user;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "invalid users" = [ "root" ];
          workgroup = "WORKGROUP";
          "server string" = "smbnix";
          "netbios name" = "smbnix";
          security = "user";
          "guest account" = user.name;
          "passwd program" = "/run/wrappers/bin/passwd %u";
        };
        nas = {
          path = "/nas";
          browsable = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0777";
          "directory mask" = "0777";
        };
      };
    };
    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}
