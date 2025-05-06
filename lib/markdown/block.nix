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
  part = import ./utils.nix { inherit lib combinators; };
in
rec {
  parse = choice [
    header
    rule
    indentedCodeBlock # maybe should go above header and rule
    fencedCodeBlock
    # parseList
  ];

  paragraph = greed (skipThen (someLazy part.contentLine) (skipThen part.blankLine));

  header = choice [
    headerOneLine
    (fmap (content: {
      type = "h1";
      content = content;
    }) (headerUnder "="))
    (fmap (content: {
      type = "h2";
      content = content;
    }) (headerUnder "-"))
  ];

  headerUnder =
    sym:
    thenSkip (someLazy part.contentLine) (sequence [
      part.smallIndent
      (some (symbol sym))
      part.blankLines
    ]);

  headerOneLine = skipThen part.smallIndent (
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
          )) (some part.whitespace)
        )
      )
      (
        alt
          # there exist ending hashtags
          (thenSkip (manyLazy anySymbol) (sequence [
            (some part.whitespace)
            (some (symbol "#"))
            part.blankLines
          ]))
          # there exist no ending hashtags
          (thenSkip (manyLazy (notSymbol "\n")) part.blankLines)
      )
  );

  fencedCodeBlock = choice (
    map
      (
        char:
        let
          # TODO: think of reason to make this not greedy
          parseStartTicks = filter (lst: lst >= 3) (fmap builtins.length (greedy1 (symbol char)));
          parseInfoString = skipThen (greedy part.whitespace) (manyLazy (notSymbol "\n"));
          # has amount of spaces, amount of ticks and info string
          firstLine = sequence [
            part.smallIndent
            parseStartTicks
            (thenSkip parseInfoString part.blankLine)
          ];
          # has the body of the code block, needs the amount of spaces
          content =
            indent: many (pack (greed (upTo part.whitespace indent)) (many (notSymbol "\n")) part.lineEnd);
          # needs the amount of ticks
          lastLine =
            fstLen:
            skipThen part.smallIndent (filter (lst: builtins.length lst >= fstLen) (greedy1 (symbol char)));
        in
        fmap
          (
            {
              indent,
              type,
              ticks,
              info,
              content,
            }:
            {
              inherit type content info;
            }
          )
          (
            bind (bind firstLine (
              first:
              fmap (cont: {
                indent = builtins.elemAt first 0;
                type = "code";
                ticks = builtins.elemAt first 1;
                info = builtins.elemAt first 2;
                content = cont;
              }) (content (builtins.elemAt first 0))
            )) ({ ticks, ... }@block: fconst block (lastLine ticks))
          )
      )
      [
        "~"
        "`"
      ]
  );

  rule = fconst { type = "hr"; } (
    pack part.smallIndent (choice (
      map (char: filter (lst: builtins.length lst >= 3) (listOf (symbol char) (many part.whitespace))) [
        "*"
        "-"
        "_"
      ]
    )) part.blankLines
  );

  indentedCodeBlock =
    let
      parseCodeIndent = filter (len: len == tabSize) part.indent;
      parseCodeLine = pack parseCodeIndent (some (notSymbol "\n")) part.lineEnd;
      parseBlockCore = app (fmap (old: new: old ++ [ new ]) (
        many (alt parseCodeLine (fconst [ ] (skipThen (upTo part.whitespace tabSize) part.lineEnd)))
      )) parseCodeLine;
    in
    fmap (lines: {
      type = "code";
      content = lines;
      info = [ ];
    }) (thenSkip parseBlockCore (greedy part.blankLine));

  # TODO: html blocks

}
