{
  pkgs,
}:
let
  lib = pkgs.lib;
in
rec {
  combinators = import ./parser_combinators {
    inherit lib;
  };

  markdown = import ./markdown {
    inherit lib combinators;
  };
}
