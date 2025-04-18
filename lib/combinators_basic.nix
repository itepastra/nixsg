{
  lib,
}:
/**
  # Type
  ```
  Parser :: {str :: string; pos :: int; len :: int} -> [(parsed :: r, rest ::
  {str :: string; pos :: int; len :: int})]
  ```

  str: the whole string
  pos: the index that's currently selected
  len: the maximum allowed index
*/
let
  inherit (builtins) elemAt;
  inherit (lib) lists;
  current =
    {
      str,
      pos,
      len,
    }:
    elemAt str pos;
  inRange =
    {
      str,
      pos,
      len,
    }:
    pos < len;
  next =
    {
      str,
      pos,
      len,
    }:
    {
      inherit str len;
      pos = pos + 1;
    };
in
{
  anySymbol =
    s:
    if inRange s then
      [
        {
          parsed = current s;
          new = next s;
        }
      ]
    else
      [ ];

  satisfy =
    predicate: s:
    if inRange s && predicate (current s) then
      [
        {
          parsed = current s;
          new = next s;
        }
      ]
    else
      [ ];

  empty = s: [ ];

  succeed = ret: s: [
    {
      parsed = ret;
      new = s;
    }
  ];

  # <|>
  alt =
    p1: p2: s:
    p1 s ++ p2 s;

  # <*>
  app =
    p: q: xs:
    let
      # [ {parsed = function; new = ...} ]
      fys = (p xs);
      # [ [ {parsed = value; new = ...} ] ]
      xzs = map (fy: q fy.new) fys;
    in
    lists.concatMap (
      { fst, snd }:
      map (
        { parsed, new }:
        {
          parsed = fst.parsed parsed;
          new = new;
        }
      ) snd
    ) (lists.zipLists fys xzs);

}
