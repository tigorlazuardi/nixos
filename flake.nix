{
  description = "Tigor's Nixos Configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };
  inputs = {
    zen-browser.url = "github:MarceColl/zen-browser-flake";
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
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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
        nur.nixosModules.nur
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
            nur.overlay
            rust-overlay.overlays.default
            (final: prev: { zen-browser = inputs.zen-browser.packages."${system}".default; })
            (final: prev: { ags-agenda = inputs.ags-agenda.packages."${system}".default; })
          ];
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
          ];
        }
      ];
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        castle =
          let
            profile-path = ./profiles/castle.nix;
            hardware-configuration = ./hardware-configuration/castle.nix;
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
                home-manager.users.tigor = import ./home;
              }
            ] ++ commonModules;
            specialArgs = specialArgs;
          };
        fort =
          let
            profile-path = ./profiles/fort.nix;
            hardware-configuration = ./hardware-configuration/fort.nix;
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
                home-manager.users.tigor = import ./home;
              }
            ] ++ commonModules;
            specialArgs = specialArgs;
          };
        homeserver =
          let
            profile-path = ./profiles/homeserver.nix;
            hardware-configuration = ./hardware-configuration/homeserver.nix;
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
                home-manager.users.homeserver = import ./home;
              }
            ] ++ commonModules;
            specialArgs = specialArgs;
          };
      };
    };
}
