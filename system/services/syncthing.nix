{ config, lib, ... }:
let
  cfg = config.profile.services.syncthing;
  user = config.profile.user;
  uid = toString user.uid;
  gid = toString user.gid;
  dataDir = "/nas/Syncthing";
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    system.activationScripts.syncthing = ''
      mkdir -p ${dataDir}
      chown ${uid}:${gid} ${dataDir}
    '';
    services.caddy.virtualHosts."syncthing.tigor.web.id".extraConfig = ''
      reverse_proxy 0.0.0.0:8384
    '';

    services.nginx.virtualHosts."syncthing.tigor.web.id" = {
      useACMEHost = "tigor.web.id";
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://0.0.0.0:8384";
          proxyWebsockets = true;
        };
      };
    };

    security.acme.certs."tigor.web.id".extraDomainNames = [ "syncthing.tigor.web.id" ];
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
          "/nas/redmage/images/s20fe-sfw" = {
            label = "Redmage/S20FE";
            id = "Redmage/S20FE";
            devices = [ "s20fe" ];
          };
          "/nas/Syncthing/Sync/Japanese-Homework" = {
            label = "Japanese Homework";
            id = "Japanese-Homework";
            devices = [
              "s20fe"
              "onyx"
              "windows"
            ];
          };
          "/nas/kavita/library/light-novels" = {
            label = "Light Novels";
            id = "Light-Novels";
            devices = [ "onyx" ];
          };
          "/nas/Syncthing/Sync/VPN" = {
            label = "OpenVPN";
            id = "OpenVPN";
            devices = [
              "s20fe"
              "work-laptop"
            ];
          };
          "/nas/Syncthing/Sync/WireGuard" = {
            label = "WireGuard";
            id = "WireGuard";
            # devices = lib.attrsets.mapAttrsToList (key: _value: key) config.services.syncthing.settings.devices;
            devices = [
              "s20fe"
              "work-laptop"
            ];
          };
          "/nas/photos/mama" = {
            label = "Camera Mama";
            id = "sm-s906e_8dch-photos";
            devices = [ "samsung-s22-mama" ];
          };
          "/nas/photos/tigor" = {
            label = "Camera Tigor";
            id = "sm-g780f_yjwa-photos";
            devices = [ "s20fe" ];
          };
          "/nas/Syncthing/Sync/Onyx-Notes" = {
            label = "Onyx Notes";
            id = "Onyx-Notes";
            devices = [ "onyx" ];
          };
          "/nas/Syncthing/Sync/Japanese-Learning-Materials" = {
            label = "Japanese Learning Materials";
            id = "Japanese-Learning-Materials";
            devices = [
              "s20fe"
              "work-laptop"
            ];
          };
          "/nas/Syncthing/Sync/Memes" = {
            label = "Memes";
            id = "Memes";
            devices = [
              "s20fe"
              "work-laptop"
            ];
          };
          "/nas/EmuDeck" = {
            label = "EmuDeck";
            id = "EmuDeck";
            devices = [
              "steam-deck"
              "windows"
              "living-room-system"
            ];
          };
          "/nas/Syncthing/Sync/sops" = {
            label = "Sops";
            id = "Sops";
            devices = [
              "s20fe"
              "work-laptop"
              "windows"
            ];
          };
          "/nas/Syncthing/Sync/Music" = {
            label = "Music";
            id = "Music";
            devices = [
              "s20fe"
              "work-laptop"
              "windows"
              "living-room-system"
            ];
          };
          "/nas/Syncthing/Sync/General" = {
            label = "General";
            id = "General";
            devices = [
              "s20fe"
              "work-laptop"
              "windows"
              "living-room-system"
            ];
          };
          "/nas/Syncthing/Sync/Public" = {
            label = "Public";
            id = "Public";
            devices = [
              "s20fe"
              "work-laptop"
              "windows"
              "living-room-system"
            ];
          };
        };
        devices = {
          s20fe = {
            name = "Samsung S20FE";
            id = "ASH4PGY-H2ANIMX-RJJRODR-AD6KH5X-632CAG2-5NCDSGN-I27XNAC-EMVL6A7";
          };
          onyx = {
            name = "Onyx Note Air 3";
            id = "FZMFBD5-5PS566H-XJGV3FO-NQVSMX5-3VHPS7V-SUT27WA-MXHFBYT-BDSS6AW";
          };
          windows = {
            name = "Windows";
            id = "FSTIYS6-REFXIJX-KPLYC4L-QSZO46L-RV3VTPZ-VWVTE7O-Y663OZN-RTKP3QI";
          };
          work-laptop = {
            name = "Work Laptop";
            id = "BOU76IK-5AE7ARF-ZQDFOTX-KWUQL22-SAGXBYG-B75JRZA-L4MCYPU-OYTY5AU";
          };
          samsung-s22-mama = {
            name = "Samsung S22 Mama";
            id = "5G2Q7XE-HILUI46-GWTE6P6-NJHAG3A-HSZKMAU-K5PBOKR-QN3IFQO-GX7KTQU";
          };
          steam-deck = {
            name = "Steam Deck";
            id = "6SOR4SU-MVT2XIS-4J6IGVP-LITFLDB-ZH6LA7T-PUSQK26-P6RVWZ7-YB7P4AX";
          };
          living-room-system = {
            name = "Living Room System";
            id = "63W5VTT-X6R6WOC-LMQEXM7-6PCUYLX-UONPYFB-UYM2OGN-2TJ47HG-66TSCQC";
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
