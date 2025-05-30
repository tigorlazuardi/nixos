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
          workgroup = "WORKGROUP";
          "guest account" = user.name;
        };
        nas = {
          path = "/nas";
          browsable = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0664";
          "directory mask" = "0775";
        };
        wolf = {
          path = "/wolf";
          browsable = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0664";
          "directory mask" = "0775";
        };
      };
    };
    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}
