{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/main";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nixos-hardware,
    nix-flatpak,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    specialArgs = {inherit inputs outputs system pkgs pkgs-unstable;};
  in {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    nixpkgs = {
      # You can add overlays here
      overlays = [
        (final: prev: {
          unstable = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
        })
      ];
      # Configure your nixpkgs instance
      config = {
        # Disable if you don't want unfree packages
        allowUnfree = true;
        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        allowUnfreePredicate = _: true;
      };
    };

    nixpkgs-unstable.config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      aorus = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        # > Our main nixos configuration file <
        modules =
          [
            nix-flatpak.nixosModules.nix-flatpak
            ./nixos/configuration.nix
          ]
          ++ (with nixos-hardware.nixosModules; [
          ]);
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "ps@aorus" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = specialArgs;
        # > Our main home-manager configuration file <
        modules = [
          ./home-manager/home.nix
        ];
      };
    };
  };
}
