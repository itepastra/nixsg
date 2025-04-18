{
  lib,
  core,
}:
rec {
  # re-export the core functions
  inherit (core)
    anySymbol
    satisfy
    empty
    succeed
    alt
    app
    fmap
    look
    ;

  # fmap ignoring the result of the parser
  fconst = value: fmap (x: value);

  # variant of app ignoring the second parser
  thenSkip = p1: p2: app (fmap (x: y: x) p1) p2;

  # variant of app ignoring the first parser
  skipThen = p1: p2: app (fmap (x: y: y) p1) p2;

}
