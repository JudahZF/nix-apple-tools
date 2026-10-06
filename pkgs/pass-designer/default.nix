{
  lib,
  stdenvNoCC,
  fetchApple,
  xar,
  gzip,
  cpio,
}:
stdenvNoCC.mkDerivation {
  pname = "pass-designer";
  version = "1.0-beta2";

  src = fetchApple {
    url = "https://download.developer.apple.com/Developer_Tools/Pass_Designer_beta/Pass_Designer_beta2.pkg";
    hash = "sha256-CSugVUpwaQdLwre/KNOOmmipwAuLeKkbz19QU7GSPzw=";
    name = "Pass_Designer_beta2.pkg";
  };

  nativeBuildInputs = [
    xar
    gzip
    cpio
  ];

  dontFixup = true;
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    xar -xf "$src"
    mkdir -p payload
    gzip -dc "Pass Designer.pkg/Payload" | (cd payload && cpio -id)
    runHook postUnpack
  '';

  sourceRoot = "payload";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -R "Applications/Pass Designer.app" "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Design and preview Apple Wallet passes";
    homepage = "https://developer.apple.com/pass-designer/";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    mainProgram = "Pass Designer";
  };
}
