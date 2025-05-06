{
  lib,
  combinators,
}:
let
  tabSize = 4;
  inherit (combinators)
    fconst
    alt
    app
    anySymbol
    symbol
    notSymbol
    satisfy
    many
    manyLazy
    some
    someLazy
    bind
    string
    choice
    pack
    thenSkip
    sequence
    skipThen
    runParser
    greedy
    greedy1
    fmap
    fmapCons
    filter
    upTo
    listOf
    greed
    ;
in
rec {
  block = import ./block.nix { inherit lib combinators; };
  utils = import ./utils.nix { inherit lib combinators; };
  inline = import ./inline.nix { inherit lib combinators; };

  parseFile = filename: parseString (builtins.readFile (./. + filename));
  parseString = runParser (many block.parse);
}
