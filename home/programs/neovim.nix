{ config, pkgs, lib, ... }:
let
  cfg = config.profile.neovim;
  inherit (lib) mkIf;
  repository = "git@github.com:tigorlazuardi/nvim.git";
  nvimCloneDir = "${config.home.homeDirectory}/.config/nvim";
in
{
  config = mkIf cfg.enable {
    systemd.user.services.clone-nvim = {
      Unit = {
        Description = "Clone neovim configuration if not exists";
        Wants = [ "network-online.target" ];
        After = [ "nss-lookup.target" ];
        StartLimitIntervalSec = 300;
        StartLimitBurst = 10;
      };
      Service =
        let
          git = "${pkgs.git}/bin/git";
          bash = "${pkgs.bash}/bin/bash";
          ping = "${pkgs.unixtools.ping}/bin/ping";
          host = "github.com";
          sleep = "${pkgs.coreutils}/bin/sleep";
          script = pkgs.writeScriptBin "clone-nvim.sh" /*bash*/ ''
            #!${bash}

            if [ -d "${nvimCloneDir}" ]; then
                exit 0;
            fi

            until ${ping} -c 1 ${host}; do
                ${sleep} 1;
            done

            mkdir -p ${nvimCloneDir}

            ${git} clone ${repository} ${nvimCloneDir}
          '';
          path = "${script}/bin/clone-nvim.sh";
        in
        {
          Type = "simple";
          ExecStart = "${bash} ${path}";
          Restart = "on-failure";
          RemainAfterExit = "yes";
          Environment = [
            ''GIT_SSH_COMMAND=${pkgs.openssh}/bin/ssh -i ${config.sops.secrets."ssh/id_ed25519/private".path}''
          ];
        };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    sops.secrets."copilot" = {
      path = "${config.home.homeDirectory}/.config/github-copilot/hosts.json";
    };

    home.packages = with pkgs; [
      stylua
      docker-compose-language-service
      emmet-ls
      silicon # For code screenshots
      lua-language-server
      taplo
      yaml-language-server
      vscode-langservers-extracted

      curl
      cargo
      nixpkgs-fmt
      nil

      gcc
      python3

      # Docker tools
      dockerfile-language-server-nodejs
      hadolint

    ];
  };
}
