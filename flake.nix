{
  description = "Tigor's Nixos Configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://walker.cachix.org"
      "https://walker-git.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
      "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
    ];
  };
  inputs = {
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    walker.url = "github:abenz1267/walker";
    nur.url = "github:nix-community/NUR";
    ags-agenda.url = "git+https://git.tigor.web.id/tigor/AGS?ref=main";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    stylix.url = "github:danth/stylix/release-24.11";
    catppuccin.url = "github:catppuccin/nix";

    #### Nix Vim
    nixvim = {
      url = "github:nix-community/nixvim";
      # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    snacks-nvim = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };
    trouble-nvim = {
      url = "github:folke/trouble.nvim";
      flake = false;
    };
    lzn-auto-require-nvim = {
      url = "github:horriblename/lzn-auto-require";
      flake = false;
    };
    tiny-inline-diagnostic-nvim = {
      url = "github:rachartier/tiny-inline-diagnostic.nvim";
      flake = false;
    };
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    nvim-aider = {
      url = "github:GeorgesAlkhouri/nvim-aider";
      flake = false;
    };
    neotest = {
      url = "github:nvim-neotest/neotest";
      flake = false;
    };
    tiny-code-action = {
      url = "github:rachartier/tiny-code-action.nvim";
      flake = false;
    };
    neotab-nvim = {
      url = "github:kawre/neotab.nvim";
      flake = false;
    };
    nvim-treesitter-endwise = {
      url = "github:brianhuster/nvim-treesitter-endwise";
      flake = false;
    };
    nvim-dap-view = {
      url = "github:igorlfs/nvim-dap-view";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      mkNixosConfiguration = (
        {
          profile-path,
          hardware-configuration,
          user,
        }:
        let
          specialArgs = {
            inherit
              inputs
              unstable
              profile-path
              hardware-configuration
              ;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./system
            {
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${user} = import ./home;
            }
          ];
          specialArgs = specialArgs;
        }
      );
    in
    {
      nixosConfigurations = {
        castle = mkNixosConfiguration {
          profile-path = ./profiles/castle.nix;
          hardware-configuration = ./hardware-configuration/castle.nix;
          user = "tigor";
        };
        fort = mkNixosConfiguration {
          profile-path = ./profiles/fort.nix;
          hardware-configuration = ./hardware-configuration/fort.nix;
          user = "tigor";
        };
        homeserver = mkNixosConfiguration {
          profile-path = ./profiles/homeserver.nix;
          hardware-configuration = ./hardware-configuration/homeserver.nix;
          user = "homeserver";
        };
      };
    };
}
