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
      securityType = "user";
      openFirewall = true;
      extraConfig = ''
        workgroup = WORKGROUP
        server string = smbnix
        netbios name = smbnix
        security = user 
        guest account = ${user.name}
      '';
      shares = {
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
