{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  nativeBuildInputs = [ pkgs.cargo pkgs.nasm pkgs.python3 (pkgs.buildPackages.ghc.withPackages (p: [p.utility-ht p.criterion p.ilist p.MissingH p.sort])) ];
}
