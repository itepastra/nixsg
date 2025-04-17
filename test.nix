{
  pkgs,
  nlib,
}:
{
  test_62 = {
    expr = builtins.map nlib.header [
      "# foo"
      "## foo"
      "### foo"
      "#### foo"
      "##### foo"
      "###### foo"
    ];
    expected = [
      {
        type = "h1";
        content = "foo";
      }
      {
        type = "h2";
        content = "foo";
      }
      {
        type = "h3";
        content = "foo";
      }
      {
        type = "h4";
        content = "foo";
      }
      {
        type = "h5";
        content = "foo";
      }
      {
        type = "h6";
        content = "foo";
      }
    ];
  };
  test_63 = {
    expr = nlib.header "####### foo";
    expected = {
      type = "p";
      content = "####### foo";
    };
  };
  test_64 = {
    expr = builtins.map nlib.header [
      "#5 bolt"
      "#hashtag"
    ];
    expected = [
      {
        type = "p";
        content = "#5 bolt";
      }
      {
        type = "p";
        content = "#hashtag";
      }
    ];
  };
}
