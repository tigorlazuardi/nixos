{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.profile.hyprland;
in
{
  imports = [
    inputs.walker.homeManagerModules.default
  ];
  config = lib.mkIf cfg.enable {
    programs.walker = {
      enable = true;
      package = pkgs.walker;
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
              ''kitty --title="Project: %RESULT%" --working-directory="%RESULT%"'';
          }
          (
            let
              pactl = lib.meta.getExe' pkgs.pulseaudio "pactl";
              jq = lib.meta.getExe' pkgs.jq "jq";
            in
            {
              name = "audio";
              placeholder = "Select Audio Output";
              show_icon_when_single = true;
              src = # sh
                "${pactl} -f json list sinks | ${jq} -r '.[].description'";
              cmd = # sh
                ''
                  ${pactl} -f json list sinks | ${jq} -r '.[] | select(.description == "%RESULT%") | .name' | xargs -0I{} ${pactl} set-default-sink {};
                '';
            }
          )
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
        "$mod, A, exec, walker --modules audio"
        "$mod, semicolon, exec, walker"
      ];
    };
  };
}
