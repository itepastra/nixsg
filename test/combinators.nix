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
    look
    fconst
    thenSkip
    skipThen
    symbol
    token
    string
    pack
    sequence
    choice
    option
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

  test_look_1 = test look "foo" [
    {
      parsed = chars "foo";
      new = mkstr "foo";
    }
  ];

  # Combinator utils

  test_fconst_1 = test (fconst 3 anySymbol) "foo" [
    {
      parsed = 3;
      new = mkstrpos "foo" 1;
    }
  ];

  test_thenSkip_1 = test (thenSkip anySymbol anySymbol) "bar" [
    {
      parsed = "b";
      new = mkstrpos "bar" 2;
    }
  ];

  test_skipThen_1 = test (skipThen anySymbol anySymbol) "bar" [
    {
      parsed = "a";
      new = mkstrpos "bar" 2;
    }
  ];

  test_symbol_1 = test (symbol "f") "foo" [
    {
      parsed = "f";
      new = mkstrpos "foo" 1;
    }
  ];

  test_token_1 =
    test
      (token [
        "f"
        "o"
        "o"
      ])
      "foobar"
      [
        {
          parsed = chars "foo";
          new = mkstrpos "foobar" 3;
        }
      ];

  test_string_1 = test (string "foo") "foobar" [
    {
      parsed = chars "foo";
      new = mkstrpos "foobar" 3;
    }
  ];

  test_pack_1 = test (pack (string "foo") (anySymbol) (string "ar")) "foobar" [
    {
      parsed = "b";
      new = mkstrpos "foobar" 6;
    }
  ];

  test_sequence_1 =
    test
      (sequence [
        (symbol "f")
        (string "oo")
        (symbol "b")
        anySymbol
        anySymbol
      ])
      "foobar"
      [
        {
          parsed = [
            "f"
            (chars "oo")
            "b"
            "a"
            "r"
          ];
          new = mkstrpos "foobar" 6;
        }
      ];

  test_choice_1 =
    test
      (choice [
        anySymbol
        (string "foo")
        (string "fooba")
      ])
      "foobar"
      [
        {
          parsed = "f";
          new = mkstrpos "foobar" 1;
        }
        {
          parsed = chars "foo";
          new = mkstrpos "foobar" 3;
        }
        {
          parsed = chars "fooba";
          new = mkstrpos "foobar" 5;
        }
      ];

  test_option_1 = test (option (string "foo") (chars "hi")) "foo" [
    {
      parsed = chars "foo";
      new = mkstrpos "foo" 3;
    }
    {
      parsed = chars "hi";
      new = mkstrpos "foo" 0;
    }
  ];
  test_option_2 = test (option (string "foo") (chars "hi")) "bar" [
    {
      parsed = chars "hi";
      new = mkstrpos "bar" 0;
    }
  ];

}
