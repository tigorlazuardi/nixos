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
  };
  outputs =
    inputs@{
      nur,
      nixpkgs,
      home-manager,
      sops-nix,
      neovim-nightly-overlay,
      nix-index-database,
      rust-overlay,
      nix-flatpak,
      ...
    }:
    let
      system = "x86_64-linux";
      commonModules = [
        nur.modules.nixos.default
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        nix-index-database.nixosModules.nix-index
        {
          programs.command-not-found.enable = false;
          programs.nix-index-database.comma.enable = true;
        }
        {
          nixpkgs.overlays = [
            neovim-nightly-overlay.overlays.default
            nur.overlays.default
            rust-overlay.overlays.default
          ] ++ import ./overlays { inherit system inputs; };
        }
        {
          nix.settings = {
            substituters = [
              "https://cache.nixos.org/"
              "https://nix-community.cachix.org"
            ];
            trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
          };
        }
        sops-nix.nixosModules.sops
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [
            nix-index-database.hmModules.nix-index
            inputs.sops-nix.homeManagerModules.sops
            inputs.walker.homeManagerModules.default
            { programs.nix-index.enable = true; }
          ];
        }
      ];
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
          ] ++ commonModules;
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
