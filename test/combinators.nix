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
    succeed
    alt
    app
    fmap
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

  test_succeed_1 = test (succeed "a") "foo" [
    {
      parsed = "a";
      new = mkstr "foo";
    }
  ];
  test_succeed_2 = test (succeed "b") "" [
    {
      parsed = "b";
      new = mkstr "";
    }
  ];

  test_alt_1 = test (alt (succeed "a") (satisfy (a: a == "f"))) "foo" [
    {
      parsed = "a";
      new = mkstr "foo";
    }
    {
      parsed = "f";
      new = mkstrpos "foo" 1;
    }
  ];
  test_alt_2 = test (alt empty anySymbol) "foo" [
    {
      parsed = "f";
      new = mkstrpos "foo" 1;
    }
  ];
  test_alt_3 = test (alt anySymbol empty) "foo" [
    {
      parsed = "f";
      new = mkstrpos "foo" 1;
    }
  ];
  test_alt_4 = test (alt empty empty) "foo" [ ];

  test_app_1 = test (app (succeed (a: a == "f")) anySymbol) "foo" [
    {
      parsed = true;
      new = mkstrpos "foo" 1;
    }
  ];

  test_fmap_1 = test (fmap (a: a == "f") anySymbol) "foo" [
    {
      parsed = true;
      new = mkstrpos "foo" 1;
    }
  ];
  test_fmap_2 = test (fmap (a: a == "f") (alt anySymbol anySymbol)) "foo" [
    {
      parsed = true;
      new = mkstrpos "foo" 1;
    }
    {
      parsed = true;
      new = mkstrpos "foo" 1;
    }
  ];

}
