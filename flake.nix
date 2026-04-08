{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cli.url = "github:nix-community/nixos-cli";
    nix-alien.url = "github:thiagokokada/nix-alien";
    fcitx5-lotus = {
      url = "github:LotusInputMethod/fcitx5-lotus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    freesmlauncher.url = "github:FreesmTeam/FreesmLauncher/develop";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nur,
      nix-alien,
      ...
    }@inputs:
    {
      # use "nixos", or your hostname as the name of the configuration
      # it's a better practice than "default" shown in the video
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
      nixosConfigurations.huybin1234b-vivobook = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          inputs.home-manager.nixosModules.default
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.nixos-cli.nixosModules.nixos-cli

          { nixpkgs.config.allowUnfree = true; }
          (
            { pkgs, ... }:
            {
              environment.systemPackages = [
                inputs.nix-alien.packages.${pkgs.system}.nix-alien
              ];
              programs.nix-ld.enable = true;
            }
          )
        ];
      };
    };
}
