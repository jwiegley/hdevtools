{ cabal, cmdargs, ghcPaths, network, syb, time }:

cabal.mkDerivation (self: {
  pname = "hdevtools";
  version = "0.1.0.5";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  buildDepends = [ cmdargs ghcPaths network syb time ];
  postInstall = ''
    mv $out/bin/hdevtools $out/bin/.hdevtools-wrapped
    cat - > $out/bin/hdevtools <<EOF
    #! ${self.stdenv.shell}
    COMMAND=\$1
    shift
    export LD_LIBRARY_PATH=$out/lib/ghc-${self.ghc.version}/${self.pname}-${self.version}
    eval exec $out/bin/.hdevtools-wrapped \$COMMAND \$( ${self.ghc.GHCGetPackages} ${self.ghc.version} | tr " " "\n" | tail -n +2 | paste -d " " - - | sed 's/.*/-g "&"/' | tr "\n" " ") "\$@"
    EOF
    chmod +x $out/bin/hdevtools
  '';
  meta = {
    homepage = "https://github.com/bitc/hdevtools/";
    description = "Persistent GHC powered background server for FAST haskell development tools";
    license = self.stdenv.lib.licenses.mit;
    platforms = self.ghc.meta.platforms;
  };
})
