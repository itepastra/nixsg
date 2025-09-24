{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  selfPkgs = inputs.nixsg.packages.${pkgs.system};
  inherit (builtins)
    mapAttrs
    ;
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    mkDefault
    mapAttrs'
    nameValuePair
    path
    ;
  cfg = config.nixsg.nginx;
in
{
  options.nixsg.nginx = {
    enable = mkEnableOption "nginx serving of website";
    url = mkOption {
      type = with types; uniq str;
      description = "What the base-url (virtualhost) of the site should be";
    };
    nixsgRoutes = mkOption {
      type = types.path;
      description = "the routes file";
    };
  };

  config = mkIf cfg.enable ({
    services.nginx = {
      enable = true;
      virtualHosts."${cfg.url}" = {
        addSSL = mkDefault false;
        enableACME = mkDefault false;
        extraConfig = ''
          rewrite ^/(.*)/$ /$1 permanent;
        '';
        locations = mapAttrs' (name: value: nameValuePair ("= ${name}") (value)) (
          import cfg.nixsgRoutes (import ./helpers.nix { inherit pkgs selfPkgs; })
        );
      };
    };
  });
}
