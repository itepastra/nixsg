{
  pkgs,
  nlib,
}:
let
  inherit (nlib.markdown)
    parseHeader
    parseIndent
    ;

  chars = pkgs.lib.strings.stringToCharacters;

  test = parser: str: exp: {
    expr = pkgs.lib.traceValSeq (nlib.combinators.runParser parser str);
    expected = exp;
  };
in
{
  test_header_1 = test parseHeader "# hi :3\n" [
    {
      type = "h1";
      content = chars "hi :3";
    }
  ];
  test_header_2 = test parseHeader "## hi # :3# ##\n" [
    {
      type = "h2";
      content = chars "hi # :3#";
    }
    {
      type = "h2";
      content = chars "hi # :3# ##";
    }
  ];
  test_header_3 = test parseHeader "  ### hi :3\n" [
    {
      type = "h3";
      content = chars "hi :3";
    }
  ];
  test_header_4 = test parseHeader "    ## hi\n" [ ];
  test_header_5 = test parseHeader "#### # hi\n" [
    {
      type = "h4";
      content = chars "# hi";
    }
  ];
  test_header_6 = test parseHeader "##### hi  \n" [
    {
      type = "h5";
      content = chars "hi";
    }
    {
      type = "h5";
      content = chars "hi ";
    }
    {
      type = "h5";
      content = chars "hi  ";
    }
  ];
  test_header_7 = test parseHeader "###### woah  #  \n" [
    {
      type = "h6";
      content = chars "woah";
    }
    {
      type = "h6";
      content = chars "woah ";
    }
    {
      type = "h6";
      content = chars "woah  #";
    }
    {
      type = "h6";
      content = chars "woah  # ";
    }
    {
      type = "h6";
      content = chars "woah  #  ";
    }
  ];
  test_header_8 = test parseHeader "##   HI\n" [
    {
      type = "h2";
      content = chars "HI";
    }
    {
      type = "h2";
      content = chars " HI";
    }
    {
      type = "h2";
      content = chars "  HI";
    }
  ];

  test_parseIndent_1 = test parseIndent "   hii" [
    3
    2
    1
    0
  ];
  test_parseIndent_2 = test parseIndent " \t \tfoo" [
    10
    6
    5
    1
    0
  ];
}
