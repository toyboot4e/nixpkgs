# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, SDL }:

cabal.mkDerivation (self: {
  pname = "SDL";
  version = "0.6.5";
  sha256 = "1vlf1bvp4cbgr31qk6aqikhgn9jbgj7lrvnjzv3ibykm1hhd6vdb";
  extraLibraries = [ SDL ];
  meta = {
    description = "Binding to libSDL";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
