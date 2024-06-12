{ ... }:
{
  imports = [
    ../options
  ];

  profile = {
    hostname = "fort";
    hyprland = {
      enable = true;
      settings = {
        monitors = [
          ",preferred,auto,1"
        ];
        workspaces = [
          "1,default:true"
          "2"
          "3"
          "4"
          "5"
          "6"
          "7"
          "8"
          "9"
          "10"
        ];
      };
      waybar.persistent-workspaces = {
        eDP-1 = [ 1 2 3 4 5 6 7 8 9 10 ];
      };
      pyprland.wallpaper-dirs = [ "/home/tigor/Syncthing/Redmage/Laptop-Kerja" ];
      wallust.alpha = 80;
    };
    discord.enable = true;
    slack.enable = true;
    whatsapp.enable = true;
    syncthing.enable = true;
    bluetooth.enable = true;

    firefox.enable = true;

    brightnessctl.enable = true;
    keyboard.language.japanese = true;
  };
}
