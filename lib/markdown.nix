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
    string
    choice
    pack
    thenSkip
    sequence
    skipThen
    runParser
    fmap
    filter
    upTo
    ;
in
rec {
  parseFile = filename: parseString (builtins.readFile (./. + filename));

  parseString = runParser (many parseBlock);

  parseSpace = symbol " ";
  parseTab = symbol "\t";
  parseWhitespace = alt parseSpace parseTab;
  # a line ending is a line feed, carriage return or both in that order
  # TODO: other line endings
  parseLineEnd = symbol "\n";
  # a blank line contains no characters or only spaces/tabs until the newline
  parseBlankLine = thenSkip (many parseWhitespace) parseLineEnd;
  # TODO: unicode
  # parseUnicodeWhitespace = choice (
  #   map string [
  #     " "
  #     "\t"
  #     "\n"
  #     # TODO: find the rest of the valid chars
  #   ]
  # );
  # parseUnicodePunct = choice [];

  parseAsciiControl = choice [
    # TODO: ascii control parsing
  ];
  parseAsciiPunct = choice (
    map symbol (lib.strings.stringToCharacters "!\"#%&'()*+,-./:;<=>?@[\\]^_`{|}~")
  );

  parseIndent = fmap (lib.lists.foldr (acc: parsed: acc + parsed) 0) (
    many (choice [
      (fconst 1 parseSpace)
      (fconst tabSize parseTab)
    ])
  );

  parseBlock = choice [
    parseHeader
    # parseRule
    # parseCodeBlock
    # parseList
  ];

  parseLine = choice [ ];

  parseHeader = choice [
    parseHeaderOneLine
  ];

  parseHeaderOneLine = skipThen (filter (a: a < tabSize) parseIndent) (
    app
      (fmap
        (amt: content: {
          type = "h${builtins.toString amt}";
          content = content;
        })
        (
          thenSkip (choice (
            map (c: fconst (builtins.stringLength c) (string c)) [
              "#"
              "##"
              "###"
              "####"
              "#####"
              "######"
            ]
          )) (some parseWhitespace)
        )
      )
      (
        alt
          # there exist ending hashtags
          (thenSkip (someLazy anySymbol) (sequence [
            (some parseWhitespace)
            (some (symbol "#"))
            (many parseWhitespace)
            parseLineEnd
          ]))
          # there exist no ending hashtags
          (thenSkip (someLazy (notSymbol "\n")) (thenSkip (many parseWhitespace) parseLineEnd))
      )
  );
}
