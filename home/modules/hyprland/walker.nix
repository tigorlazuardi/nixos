{
  config,
  unstable,
  lib,
  ...
}:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    programs.walker = {
      enable = true;
      package = unstable.walker;
      runAsService = true;
      config = {
        hotreload_theme = true;
        builtins.windows.weight = 100;
        builtins.clipboard = {
          prefix = ''"'';
          always_put_new_on_top = true;
        };
        plugins = [
          {
            name = "Projects";
            placeholder = "Projects";
            show_icon_when_single = true;
            src = "zoxide query --list";
            weight = 20;
            cmd = # sh
              ''footclient --title="Project: %RESULT%" --working-directory="%RESULT%"'';
          }
        ];
        keys = {
          next = [
            "down"
            "ctrl n"
          ];
          prev = [
            "up"
            "ctrl p"
          ];
          accept_typeahead = [
            "tab"
            "ctrl y"
          ];
        };
      };
    };

    # Restart walker when the config file changes. We have to
    # target the source path in the store.
    #
    # https://github.com/abenz1267/walker/blob/master/nix/hm-module.nix#L71
    systemd.user.services.walker.Unit.X-Restart-Triggers = [
      "${config.xdg.configFile."walker/config.toml".source}"
    ];

    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mod, D, exec, walker"
        "$mod, semicolon, exec, walker"
      ];
    };
  };
}
