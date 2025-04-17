{
  pkgs,
}:
let
  lib = pkgs.lib;
in
{
  # Markdown to HTML
  markdownToHTML =
    markdownString:
    let
      lines = lib.splitString "\n" markdownString;
      blocks =
        let
          header =
            line:
            if lib.hasPrefix "# " line then
              {
                content = lib.substring (lib.stringLength "# ") (lib.stringLength line) line;
                type = "h1";
              }
            else if lib.hasPrefix "## " line then
              {
                content = lib.substring (lib.stringLength "## ") (lib.stringLength line) line;
                type = "h2";
              }
            else if lib.hasPrefix "### " line then
              {
                content = lib.substring (lib.stringLength "### ") (lib.stringLength line) line;
                type = "h3";
              }
            else if lib.hasPrefix "#### " line then
              {
                content = lib.substring (lib.stringLength "#### ") (lib.stringLength line) line;
                type = "h4";
              }
            else if lib.hasPrefix "##### " line then
              {
                content = lib.substring (lib.stringLength "##### ") (lib.stringLength line) line;
                type = "h5";
              }
            else if lib.hasPrefix "###### " line then
              {
                content = lib.substring (lib.stringLength "###### ") (lib.stringLength line) line;
                type = "h6";
              }
            else
              [ ];
        in
        builtins.foldl' (
          pblocks: line:
          pblocks
          ++ (
            if lib.hasPrefix "#" line then
              header line
            else if lib.match "^\s{,3}([*\-=_])(\1\s*){2,}$" line then
              { type = "hr"; }
            # TODO: all but (thematic) headings
            else
              { }
          )
        ) [ ] lines;
    in
    { };
}
