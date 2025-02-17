{
  description = "Installation example for standalone home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jetbra.url = "github:Sanfrag/nix-jetbra/master";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      jetbra,
      ...
    }:
    let
      # Replace with your username
      username = "jdoe";

      # Replace with the fitting architecture
      system = "x86_64-linux";
    in
    {
      # Replace `standAloneConfig` with the name of your configuration (your `username` or `"username@hostname"`)
      homeConfigurations.standAloneConfig = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };

        modules = [
          jetbra.homeManagerModules.jetbra

          # Specify the path to your home configuration here:
          ../home.nix

          {
            home = {
              inherit username;
              homeDirectory = "/home/${username}";
            };
          }
        ];
      };
    };
}
