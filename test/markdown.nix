{
  pkgs,
  nlib,
}:
let
  inherit (nlib.markdown)
    part
    block
    inline
    ;

  chars = pkgs.lib.strings.stringToCharacters;

  test = parser: str: exp: {
    expr = nlib.combinators.runParser parser str;
    expected = exp;
  };

  testFencedCode =
    input: contents: info:
    test block.fencedCodeBlock input (
      map (content: {
        content = map chars content;
        type = "code";
        info = chars info;
      }) contents
    );
in
{
  test_header_1 = test block.header "# hi :3\n" [
    {
      type = "h1";
      content = chars "hi :3";
    }
  ];
  test_header_2 = test block.header "## hi # :3# ##\n" [
    {
      type = "h2";
      content = chars "hi # :3#";
    }
    {
      type = "h2";
      content = chars "hi # :3# ##";
    }
  ];
  test_header_3 = test block.header "  ### hi :3\n" [
    {
      type = "h3";
      content = chars "hi :3";
    }
  ];
  test_header_4 = test block.header "    ## hi\n" [ ];
  test_header_5 = test block.header "#### # hi\n" [
    {
      type = "h4";
      content = chars "# hi";
    }
  ];
  test_header_6 = test block.header "##### hi  \n" [
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
  test_header_7 = test block.header "###### woah  #  \n" [
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
  test_header_8 = test block.header "##   HI\n" [
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

  test_indent_1 = test part.indent "   hii" [
    3
    2
    1
    0
  ];
  test_indent_2 = test part.indent " \t \tfoo" [
    10
    6
    5
    1
    0
  ];

  test_rule_1 = test block.rule "***" [ { type = "hr"; } ];
  test_rule_2 = test block.rule "---" [ { type = "hr"; } ];
  test_rule_3 = test block.rule "___" [ { type = "hr"; } ];
  test_rule_4 = test block.rule "+++" [ ];
  test_rule_5 = test block.rule "===" [ ];
  test_rule_6 = test block.rule "**" [ ];
  test_rule_7 = test block.rule "--" [ ];
  test_rule_8 = test block.rule "__" [ ];
  test_rule_9 = test block.rule " ***" [ { type = "hr"; } ];
  test_rule_10 = test block.rule "  ***" [ { type = "hr"; } ];
  test_rule_11 = test block.rule "   ***" [ { type = "hr"; } ];
  test_rule_12 = test block.rule "    ***" [ ];
  test_rule_13 = test block.rule "--------------------------" [ { type = "hr"; } ];
  test_rule_14 = test block.rule " - - -" [ { type = "hr"; } ];
  test_rule_15 = test block.rule " **  * ** * ** * **" [ { type = "hr"; } ];
  test_rule_16 = test block.rule "-     -      -       -" [ { type = "hr"; } ];
  test_rule_17 = test block.rule "- - - -    \t" [ { type = "hr"; } ];
  test_rule_18 = test block.rule "_ _ _ _ a" [ ];
  test_rule_19 = test block.rule "a------" [ ];
  test_rule_20 = test block.rule "---a---" [ ];
  test_rule_21 = test block.rule " *-*" [ ];

  test_codeBlock_1 = test block.indentedCodeBlock "    a simple
      indented code block" [
    {
      type = "code";
      content = [
        (chars "a simple")
        (chars "  indented code block")
      ];
      info = chars "";
    }
    {
      type = "code";
      content = [
        (chars "a simple")
      ];
      info = chars "";
    }
  ];
  test_codeBlock_2 = test block.indentedCodeBlock "    chunk1

    chunk2
  
 
 
    chunk3" [
    {
      type = "code";
      content = map chars [
        "chunk1"
        ""
        "chunk2"
        ""
        ""
        ""
        "chunk3"
      ];
      info = chars "";
    }
    {
      type = "code";
      content = map chars [
        "chunk1"
        ""
        "chunk2"
      ];
      info = chars "";
    }
    {
      type = "code";
      content = map chars [
        "chunk1"
      ];
      info = chars "";
    }
  ];
  test_codeBlock_3 = test block.indentedCodeBlock "    chunk1
      
      chunk2" [
    {
      type = "code";
      content = map chars [
        "chunk1"
        "  "
        "  chunk2"
      ];
      info = chars "";
    }
    {
      type = "code";
      content = map chars [
        "chunk1"
        "  "
      ];
      info = chars "";
    }
    {
      type = "code";
      content = map chars [
        "chunk1"
      ];
      info = chars "";
    }
  ];
  test_codeBlock_4 = test block.indentedCodeBlock "    foo\nbar" [
    {
      type = "code";
      content = [ (chars "foo") ];
      info = chars "";
    }
  ];
  test_codeBlock_5 = test block.indentedCodeBlock "        foo\n    bar" [
    {
      type = "code";
      content = map chars [
        "    foo"
        "bar"
      ];
      info = chars "";
    }
    {
      type = "code";
      content = map chars [
        "    foo"
      ];
      info = chars "";
    }
  ];
  test_codeBlock_6 = test block.indentedCodeBlock "    foo
    " [
    {
      type = "code";
      content = [ (chars "foo") ];
      info = chars "";
    }
  ];

  test_fencedCode_1 = testFencedCode "```
foo
```" [
    [ "foo" ]
  ] "";
  test_fencedCode_2 = testFencedCode "```
aaa
~~~
```" [
    [
      "aaa"
      "~~~"
    ]
  ] "";
  test_fencedCode_3 = testFencedCode "~~~
aaa
```
~~~" [
    [
      "aaa"
      "```"
    ]
  ] "";
  test_fencedCode_4 = testFencedCode "````
aaa
```
``````" [
    [
      "aaa"
      "```"
    ]
  ] "";
  test_fencedCode_5 = testFencedCode "~~~~
aaa
~~~
~~~~" [
    [
      "aaa"
      "~~~"
    ]
  ] "";
  test_fencedCode_6 = testFencedCode "```

  
```" [
    [
      ""
      "  "
    ]
  ] "";
  test_fencedCode_7 = testFencedCode "```
```" [ [ ] ] "";
  test_fencedCode_8 = testFencedCode " ```
 aaa
aaa
```" [
    [
      "aaa"
      "aaa"
    ]
  ] "";
  test_fencedCode_9 = testFencedCode "  ```
aaa
  aaa
aaa
  ```" [
    [
      "aaa"
      "aaa"
      "aaa"
    ]
  ] "";
  test_fencedCode_10 = testFencedCode "   ```
   aaa
    aaa
  aaa
   ```" [
    [
      "aaa"
      " aaa"
      "aaa"
    ]
  ] "";
  test_fencedCode_11 = testFencedCode "    ```
    aaa
    ```" [ ] "";
  test_fencedCode_12 = testFencedCode "```
aaa
  ```" [ [ "aaa" ] ] "";
}
