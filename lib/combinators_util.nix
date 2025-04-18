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
    ;

}
