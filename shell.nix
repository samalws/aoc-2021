{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  nativeBuildInputs = [ pkgs.cargo (pkgs.buildPackages.ghc.withPackages (p: [p.utility-ht p.criterion p.ilist p.MissingH])) ];
}
