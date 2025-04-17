{
  description = "Static site generator written using Nix";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    { nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = lib.intersectLists lib.systems.flakeExposed lib.platforms.linux;
      forAllSystems = lib.genAttrs systems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    rec {
      lib = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        import ./lib.nix { inherit pkgs; }
      );

      checks = forAllSystems (
        system:
        let
          lib = import lib { inherit system; };
        in
        {
        }
      );
    };
}
