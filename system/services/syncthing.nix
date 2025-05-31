{ config, lib, ... }:
let
  cfg = config.profile.services.syncthing;
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  dataDir = "/nas/Syncthing";
  domain = "syncthing.tigor.web.id";
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    system.activationScripts.syncthing = ''
      mkdir -p ${dataDir}
      chown ${uid}:${gid} ${dataDir}
    '';

    services.nginx.virtualHosts."${domain}" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://unix:${config.services.anubis.instances.syncthing.settings.BIND}";
          proxyWebsockets = true;
        };
      };
    };

    services.anubis.instances.syncthing.settings.TARGET = "http://0.0.0.0:8384";

    sops.secrets =
      let
        opts = {
          owner = user.name;
          sopsFile = ../../secrets/syncthing.yaml;
        };
      in
      {
        "syncthing/server/key.pem" = opts;
        "syncthing/server/cert.pem" = opts;
      };
    services.syncthing = {
      enable = true;
      key = config.sops.secrets."syncthing/server/key.pem".path;
      cert = config.sops.secrets."syncthing/server/cert.pem".path;
      settings = {
        folders = {
          "/nas/redmage/images/windows" = {
            label = "Redmage/Windows";
            id = "Redmage/Windows";
            devices = [ "windows" ];
          };
          "/nas/redmage/images/laptop-kerja" = {
            label = "Redmage/Laptop-Kerja";
            id = "Redmage/Laptop-Kerja";
            devices = [ "work-laptop" ];
          };
          "/nas/redmage/images/oppo-find-x8" = {
            label = "Redmage/oppo-find-x8";
            id = "Redmage/oppo-find-x8";
            devices = [ "oppo-find-x8" ];
          };
          "/nas/Syncthing/Sync/Windows" = {
            label = "Windows";
            id = "Windows";
            devices = [ "windows" ];
          };
          "/nas/Syncthing/Sync/WireGuard" = {
            label = "WireGuard";
            id = "WireGuard";
            # devices = lib.attrsets.mapAttrsToList (key: _value: key) config.services.syncthing.settings.devices;
            devices = [
              "work-laptop"
              "oppo-find-x8"
            ];
          };
          "/nas/Syncthing/Sync/sops" = {
            label = "Sops";
            id = "Sops";
            devices = [
              "work-laptop"
              "windows"
              "oppo-find-x8"
            ];
          };
          "/nas/Syncthing/Sync/Music" = {
            label = "Music";
            id = "Music";
            devices = [
              "work-laptop"
              "windows"
              "living-room-system"
              "oppo-find-x8"
            ];
          };
          "/nas/Syncthing/Sync/General" = {
            label = "General";
            id = "General";
            devices = [
              "work-laptop"
              "windows"
              "living-room-system"
              "oppo-find-x8"
            ];
          };
          "/nas/Syncthing/Sync/Public" = {
            label = "Public";
            id = "Public";
            devices = [
              "work-laptop"
              "windows"
              "living-room-system"
              "oppo-find-x8"
            ];
          };
        };
        devices = {
          windows = {
            name = "Windows";
            id = "FSTIYS6-REFXIJX-KPLYC4L-QSZO46L-RV3VTPZ-VWVTE7O-Y663OZN-RTKP3QI";
          };
          work-laptop = {
            name = "Work Laptop";
            id = "BOU76IK-5AE7ARF-ZQDFOTX-KWUQL22-SAGXBYG-B75JRZA-L4MCYPU-OYTY5AU";
          };
          living-room-system = {
            name = "Living Room System";
            id = "63W5VTT-X6R6WOC-LMQEXM7-6PCUYLX-UONPYFB-UYM2OGN-2TJ47HG-66TSCQC";
          };
          oppo-find-x8 = {
            name = "Oppo Find X8";
            id = "SAYTPBV-HYUWZS7-U25B53S-D6BJFSH-Q5E3PUT-ZO53LBB-QJ255QK-HJTNDAQ";
          };
        };
      };
      overrideFolders = true;
      overrideDevices = true;
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:8384";
      user = user.name;
      dataDir = dataDir;
    };
  };
}
