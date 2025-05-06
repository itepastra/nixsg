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
    filter
    look
    biased
    bind
    ;

  # mostly internal function to fmap the haskell (:) operator
  fmapCons = fmap (cur: old: [ cur ] ++ old);

  # mostly internal function to fmap the haskell `flip (:)` operator
  fmapConsReverse = fmap (cur: old: old ++ [ cur ]);

  # fmap ignoring the result of the parser
  fconst = value: fmap (x: value);

  # variant of app ignoring the second parser
  thenSkip = p1: p2: app (fmap (x: y: x) p1) p2;

  # variant of app ignoring the first parser
  skipThen = p1: p2: app (fmap (x: y: y) p1) p2;

  # parse a specific symbol
  symbol = sym: satisfy (a: a == sym);

  # parse all but a specific symbol
  notSymbol = sym: satisfy (a: a != sym);

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

  # parses zero or more of some parser, with the shortest at the start;
  manyLazy = parser: s: lib.lists.reverseList (many parser s);

  # parses one or more of some parser
  some = parser: app (fmapCons parser) (many parser);

  # parses one or more of some parser, shortest at the start
  someLazy = parser: s: lib.lists.reverseList (some parser s);

  # parses zero up to num of some parser
  upTo =
    parser: num:
    if num == 0 then succeed [ ] else alt (app (fmapCons parser) (upTo parser (num - 1))) (succeed [ ]);

  # takes a parser and a seperator, parses p seperated by s
  listOf = parser: seperator: app (fmapCons parser) (many (skipThen seperator parser));

  # takes a parser, and a string, creates the correct structure to run it.
  runParser =
    parser: str:
    (options: map (builtins.getAttr "parsed") options) (parser {
      str = lib.strings.stringToCharacters "${str}\n";
      pos = 0;
      len = builtins.stringLength "${str}\n";
    });

  greedy = parser: biased (app (fmapCons parser) (greedy parser)) (succeed [ ]);
  greedy1 = parser: app (fmapCons parser) (greedy parser);

  greed =
    parser: s:
    let
      ps = parser s;
    in
    if ps != [ ] then
      [
        (lib.head ps)
      ]
    else
      [ ];
}
