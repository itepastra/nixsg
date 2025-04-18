{
  nlib,
  pkgs,
}:
let
  formatValue =
    val:
    if (builtins.isList val || builtins.isAttrs val) then
      builtins.toJSON val
    else
      builtins.toString val;
  resultToString =
    {
      name,
      expected,
      result,
    }:
    ''
      ${name} failed: expected ${formatValue expected}, but got ${formatValue result}
    '';
  runtests =
    name: tests:
    let
      results = pkgs.lib.runTests tests;
    in
    if results != [ ] then
      builtins.throw (builtins.concatStringsSep "\n" (map resultToString results))
    else
      pkgs.runCommand "nix-flake-tests-${name}-success" { } "echo > $out";
in
{
}
