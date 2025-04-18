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

}
