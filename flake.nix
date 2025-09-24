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
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        rec {
          default = md-to-html;
          md-to-html = pkgs.python3Packages.buildPythonApplication {
            name = "md-to-html-0.0.1";
            format = "pyproject";
            src = ./parse;
            nativeBuildInputs = with pkgs.python3.pkgs; [ setuptools ];
            propagatedBuildInputs = with pkgs.python3.pkgs; [
              jinja2
              markdown
            ];
          };
        }
      );

      nixosModules = {
        nginxSite = import ./nginx.nix;
      };
    };
}
