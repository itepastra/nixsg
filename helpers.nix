{
  pkgs,
  selfPkgs,
}:
let
  inherit (pkgs) stdenv lib;
  drv =
    template: source: additional: sp:
    stdenv.mkDerivation {
      name = "markdown-compiled";
      src = ./.;
      buildPhase = ''
        ${sp.md-to-html}/bin/md-to-html ${template} ${source} ${
          lib.attrsets.foldlAttrs (
            acc: name: val:
            acc + "--${lib.strings.escapeShellArg name} ${lib.strings.escapeShellArg val}"
          ) "" additional
        }
      '';
      installPhase = ''
        mkdir -p $out
        mv output.html $out/page.html
      '';
    };
in
{
  staticFile = source: { tryFiles = "${source} =404"; };
  markdown =
    template: source: additional:
    let
      drvPath = (drv template source additional selfPkgs) + "/page.html";
      pref = builtins.dirOf drvPath;
      post = builtins.baseNameOf drvPath;
    in
    {
      root = "${pref}";
      tryFiles = "/${post} =404";
    };
  custom = attrset: attrset;
}
