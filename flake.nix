{
  description = "A flake providing a function for adding texinfo directories to the INFOPATH environment variable";
  outputs = {...}: {
    lib.addInfoPath = nixpkgs: attr:
      let
        lib = nixpkgs.lib;
        allInputs = attr.buildInputs ++ attr.nativeBuildInputs;
        drvWithInfo = lib.filter (lib.hasAttr "info") allInputs;
        infoOutputs = map (d: d.info) drvWithInfo;
        infoPaths = lib.filter lib.pathExists (map (out: "${out}/share/info") infoOutputs);
      in
        attr.overrideAttrs (finalAttrs: prevAttrs: {
          shellHook = (prevAttrs.shellHook or "") + " \n" + ''
                  export INFOPATH=${builtins.concatStringsSep ":" infoPaths}:$INFOPATH
                  '';
        });
  };
}
