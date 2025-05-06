{
  lib,
  combinators,
}:
let
  tabSize = 4;
  inherit (combinators)
    fconst
    alt
    app
    anySymbol
    symbol
    notSymbol
    satisfy
    many
    manyLazy
    some
    someLazy
    bind
    string
    choice
    pack
    thenSkip
    sequence
    skipThen
    runParser
    greedy
    greedy1
    fmap
    fmapCons
    filter
    upTo
    listOf
    greed
    ;
in
{
  space = symbol " ";
  tab = symbol "\t";
  whitespace = alt space tab;
  # a line ending is a line feed, carriage return or both in that order
  # TODO: other line endings
  lineEnd = symbol "\n";
  # a blank line contains no characters or only spaces/tabs until the newline
  blankLine = thenSkip (many whitespace) lineEnd;
  blankLines = greedy1 blankLine;
  # TODO: unicode

  smallIndent = filter (a: a < tabSize) indent;
  asciiControl = choice [
    # TODO: ascii control parsing
  ];
  asciiPunct = choice (
    map symbol (lib.strings.stringToCharacters "!\"#%&'()*+,-./:;<=>?@[\\]^_`{|}~")
  );

  indent = fmap (lib.lists.foldr (acc: parsed: acc + parsed) 0) (
    many (choice [
      (fconst 1 space)
      (fconst tabSize tab)
    ])
  );
}
