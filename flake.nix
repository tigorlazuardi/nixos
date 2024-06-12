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
    nur.url = "github:nix-community/NUR";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
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
  };
  outputs = inputs @ { self, nur, nixpkgs, home-manager, sops-nix, neovim-nightly-overlay, ... }:
    let
      commonModules = [
        nur.nixosModules.nur
        home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [
            neovim-nightly-overlay.overlays.default
            nur.overlay
          ];
        }
        {
          nix.settings = {
            substituters = [
              "https://cache.nixos.org/"
              "https://nix-community.cachix.org"
            ];
            trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
          };
        }
        sops-nix.nixosModules.sops
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
          ];
        }
      ];
      unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations =
        {
          castle =
            let
              profile-path = ./profiles/castle.nix;
              hardware-configuration = ./hardware-configuration/castle.nix;
              specialArgs = { inherit inputs unstable profile-path hardware-configuration; };
            in
            nixpkgs.lib.nixosSystem
              {
                system = "x86_64-linux";
                modules =
                  [
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
              specialArgs = { inherit inputs unstable profile-path hardware-configuration; };
            in
            nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
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
              specialArgs = { inherit inputs unstable profile-path hardware-configuration; };
            in
            nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
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
