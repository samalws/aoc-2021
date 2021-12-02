{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  nativeBuildInputs = [ (pkgs.buildPackages.ghc.withPackages (p: [p.utility-ht p.criterion])) ];
}
