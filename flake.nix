{
  description = "Static site generator written using Nix";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    {
      nixpkgs,
      self,
    }:
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
          nlib = lib.${system};
          pkgs = nixpkgsFor.${system};
        in
        {
          commonmark =
            let
              results = pkgs.lib.runTests (import ./test.nix { inherit nlib pkgs; });
              formatValue =
                val:
                if (builtins.isList val || builtins.isAttrs val) then
                  builtins.toJSON val
                else
                  builtins.toString val;
              resultToString =
                {
                  name,
                  expected,
                  result,
                }:
                ''
                  ${name} failed: expected ${formatValue expected}, but got ${formatValue result}
                '';
            in
            if results != [ ] then
              builtins.throw (builtins.concatStringsSep "\n" (map resultToString results))
            else
              pkgs.runCommand "nix-flake-tests-success" { } "echo > $out";
        }
      );
    };
}
