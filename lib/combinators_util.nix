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

}
