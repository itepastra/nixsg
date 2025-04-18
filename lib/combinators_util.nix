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
    look
    ;

  # mostly internal function to fmap the haskell (:) operator
  fmapCons = fmap (cur: old: [ cur ] ++ old);

  # fmap ignoring the result of the parser
  fconst = value: fmap (x: value);

  # variant of app ignoring the second parser
  thenSkip = p1: p2: app (fmap (x: y: x) p1) p2;

  # variant of app ignoring the first parser
  skipThen = p1: p2: app (fmap (x: y: y) p1) p2;

  # parse a specific symbol
  symbol = sym: satisfy (a: a == sym);

  # parse a streak of symbols
  # FIXME: try to find a way without tail since it's O(n) on len(symbols)
  token =
    symbols:
    if symbols == [ ] then
      succeed [ ]
    else
      app (fmapCons (symbol (builtins.head symbols))) (token (builtins.tail symbols));

  # same as token but takes a string
  string = str: token (lib.strings.stringToCharacters str);

  # take three parser, a "start", "content" and "ending",
  # only returns the value in "content"
  pack =
    start: content: ending:
    skipThen start (thenSkip content ending);

  # takes a list of parsers and runs them sequentially
  sequence =
    parsers:
    if parsers == [ ] then
      succeed [ ]
    else
      app (fmapCons (builtins.head parsers)) (sequence (builtins.tail parsers));

  # combines a list of parsers using choice
  # the matches of any of the parsers will be in the result
  choice = lib.foldr alt empty;

  # parses an optional element
  option = parser: default: alt parser (succeed default);

  # parses zero or more of some parser
  many = parser: alt (app (fmapCons parser) (many parser)) (succeed [ ]);

  # parses one or more of some parser
  some = parser: app (fmapCons parser) (many parser);

  # takes a parser and a seperator, parses p seperated by s
  listOf = parser: seperator: app (fmapCons parser) (many (skipThen seperator parser));
}
