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
    satisfy
    empty
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

  test_satisfy_1 = test (satisfy (a: a == "f")) "foo" [
    {
      parsed = "f";
      new = mkstrpos "foo" 1;
    }
  ];
  test_satisfy_2 = test (satisfy (a: a == "b")) "foo" [ ];
  test_satisfy_3 = test (satisfy (a: a != "b")) "" [ ];

  test_empty_1 = test empty "foo" [ ];
  test_empty_2 = test empty "" [ ];

}
