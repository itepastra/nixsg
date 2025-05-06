{
  lib,
  combinators,
}:
let
  inherit (combinators) choice;
in
{
  inline = choice [ ];
}
