{
  pkgs,
}:
let
  lib = pkgs.lib;
in
rec {
  # Parse a markdown header to a typed content
  header =
    line:
    (lib.findFirst (lib.getAttr "cond") { } (
      lib.attrsets.mapAttrsToList
        (str: type: {
          cond = lib.hasPrefix str line;
          out = {
            type = type;
            content = lib.trim (lib.substring (lib.stringLength str) (lib.stringLength line) line);
          };
        })
        {
          "# " = "h1";
          "## " = "h2";
          "### " = "h3";
          "#### " = "h4";
          "##### " = "h5";
          "###### " = "h6";
        }
    )).out or {
      type = "p";
      content = line;
    };
  # Markdown to HTML
  markdownToHTML =
    markdownString:
    let
      lines = lib.splitString "\n" markdownString;
      blocks = builtins.foldl' (
        pblocks: line:
        pblocks
        ++ (
          if lib.hasPrefix "#" line then
            header line
          else if lib.match "\s{,3}([\*\-=_])(\1\s*){2,}" line then
            { type = "hr"; }
          # TODO: all but (thematic) headings
          else
            {
              type = "p";
              content = line;
            }
        )
      ) [ ] lines;
    in
    { };
}
