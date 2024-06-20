{ config, lib, pkgs, ... }:
let
  cfg = config.profile.services.rust-motd;
  inherit (lib) mkIf;
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
        "filesystems"
        "last_run"
      ];
    };
  };
}
