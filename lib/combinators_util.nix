{
  lib,
  core,
}:
rec {
  # re-export the core functions
  inherit (core)
    anySymbol
    ;
}
