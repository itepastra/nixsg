{
  pkgs,
}:
let
  lib = pkgs.lib;
in
rec {
  combinatorsCore = import ./combinators_basic.nix { inherit lib; };
  combinators = import ./combinators_util.nix {
    inherit lib;
    core = combinatorsCore;
  };
}
