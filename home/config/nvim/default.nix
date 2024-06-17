{ config, pkgs, lib, unstable, ... }:
let
  cfg = config.profile.neovim;
  inherit (lib) mkIf;
  repository = "git@github.com:tigorlazuardi/nvim.git";
  nvimCloneDir = "${config.home.homeDirectory}/nvim";
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
          script = pkgs.writeScriptBin "clone-nvim.sh" ''
            #${bash}

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
          ExecStart = path;
          Restart = "on-failure";
          RemainAfterExit = "yes";
        };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    xdg.configFile.nvim = {
      source = config.lib.file.mkOutOfStoreSymlink nvimCloneDir;
      recursive = true;
    };

    sops.secrets."copilot" = {
      path = "${config.home.homeDirectory}/.config/github-copilot/hosts.json";
    };

    home.packages = with pkgs; [
      stylua
      lua-language-server
      docker-compose-language-service
      emmet-ls
      silicon # For code screenshots

      ###### Golang development tools ######
      gomodifytags
      gotests
      iferr
      curl
      cargo
      nixpkgs-fmt
      nil

      gcc
      python3
    ];
  };
}
