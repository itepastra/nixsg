{
  lib,
  combinators,
}:
let
  inherit (combinators) fmap;
  charset = str: (lib.strings.stringToCharacters str);
in
rec {

}
