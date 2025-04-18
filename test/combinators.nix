{
  pkgs,
  nlib,
}:
let
  mkstr = str: {
    str = pkgs.lib.strings.stringToCharacters str;
    pos = 0;
    len = builtins.stringLength str;
  };
  mkstrpos = str: pos: {
    str = pkgs.lib.strings.stringToCharacters str;
    pos = pos;
    len = builtins.stringLength str;
  };

  chars = pkgs.lib.strings.stringToCharacters;

  inherit (nlib.combinators)
    anySymbol
    ;

  test = func: str: exp: {
    expr = pkgs.lib.traceValSeq (func (mkstr str));
    expected = exp;
  };
in
{
  test_anySymbol_1 = test anySymbol "" [ ];
  test_anySymbol_2 = test anySymbol "foo" [
    {
      parsed = "f";
      new = mkstrpos "foo" 1;
    }
  ];
}
