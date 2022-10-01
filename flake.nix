
{
  description = "Universal dynamic translator from one architecture to other";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    naersk = {
      url = "github:nmattia/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, naersk, fenix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rust-toolchain = fenix.packages.${system}.fromToolchainFile {
          file = ./rust-toolchain.toml;
          sha256 = "8len3i8oTwJSOJZMosGGXHBL5BVuGQnWOT2St5YAUFU=";
        };
        naersk-lib = naersk.lib.${system}.override {
          cargo = rust-toolchain;
          rustc = rust-toolchain;
        };
      in rec {
        # `nix build`
        packages = {
          dytra = naersk-lib.buildPackage {
            pname = "dytra";
            root = ./.;
          };
        };

        defaultPackage = packages.dytra;

        # `nix run`
        apps.dytra = flake-utils.lib.mkApp { drv = packages.dytra; };
        defaultApp = apps.dytra;

        # `nix develop`
        devShell = pkgs.mkShell { nativeBuildInputs = [ rust-toolchain pkgs.rust-analyzer ]; };
      });
}
