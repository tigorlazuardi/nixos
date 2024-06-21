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
    sops.secrets =
      let
        opts = { owner = user.name; sopsFile = ../../secrets/syncthing.yaml; };
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
        options.urAccepted = 1; # Allow anonymous usage reporting.
        folders = {
          "/nas/redmage/images/windows" = {
            label = "Redmage/Windows";
            id = "Redmage/Windows";
            devices = [
              "windows"
            ];
          };
          "/nas/redmage/images/laptop-kerja" = {
            label = "Redmage/Laptop-Kerja";
            id = "Redmage/Laptop-Kerja";
            devices = [
              "work-laptop"
            ];
          };
          "/nas/redmage/images/s20fe-sfw" = {
            label = "Redmage/S20FE";
            id = "Redmage/S20FE";
            devices = [
              "s20fe"
            ];
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
            devices = [
              "onyx"
            ];
          };
          "/nas/Syncthing/Sync/VPN" = {
            label = "OpenVPN";
            id = "OpenVPN";
            devices = lib.attrsets.mapAttrsToList (key: _value: key) config.services.syncthing.settings.devices;
          };
        };
        devices = {
          s20fe = {
            name = "Samsung S20FE";
            id = "ASH4PGY-H2ANIMX-RJJRODR-AD6KH5X-632CAG2-5NCDSGN-I27XNAC-EMVL6A7";
            autoAcceptFolders = true;
          };
          onyx = {
            name = "Onyx Note Air 3";
            id = "FZMFBD5-5PS566H-XJGV3FO-NQVSMX5-3VHPS7V-SUT27WA-MXHFBYT-BDSS6AW";
            autoAcceptFolders = true;
          };
          windows = {
            name = "Windows";
            id = "FSTIYS6-REFXIJX-KPLYC4L-QSZO46L-RV3VTPZ-VWVTE7O-Y663OZN-RTKP3QI";
            autoAcceptFolders = true;
          };
          work-laptop = {
            name = "Work Laptop";
            id = "BOU76IK-5AE7ARF-ZQDFOTX-KWUQL22-SAGXBYG-B75JRZA-L4MCYPU-OYTY5AU";
            autoAcceptFolders = true;
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
