{ config, lib, pkgs, ... }:
let
  cfg = config.profile.services.rust-motd;
  inherit (lib) mkIf mkMerge;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fail2ban
    ];
    programs.rust-motd = {
      enable = true;
      settings = {
        banner = {
          color = "white";
          command = "${pkgs.fortune-kind}/bin/fortune-kind | ${pkgs.neo-cowsay}/bin/cowsay --random";
        };
        service_status = mkMerge [
          { }
          (mkIf config.profile.podman.pihole.enable { Pihole = "podman-pihole"; })
          (mkIf config.profile.podman.qbittorrent.enable { QBittorrent = "podman-qbittorrent"; })
          (mkIf config.profile.services.forgejo.enable { Forgejo = "forgejo"; })
        ];
        uptime = {
          prefix = "Up";
        };
        filesystems = {
          Root = "/";
          NAS = "/nas";
        };
        memory = {
          swap_pos = "beside";
        };
        last_login = {
          ${config.profile.user.name} = 1;
        };
        last_run = { };
      };
      order = [
        "banner"
        "last_login"
        "uptime"
        "memory"
        "service_status"
        "filesystems"
        "last_run"
      ];
    };
  };
}
