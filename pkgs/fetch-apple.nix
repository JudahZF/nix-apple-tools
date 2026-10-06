{
  lib,
  stdenvNoCC,
  curl,
  cacert,
}:
{
  url,
  hash,
  name ? builtins.baseNameOf url,
}:
stdenvNoCC.mkDerivation {
  inherit name;

  impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [ "APPLE_ADC_DOWNLOAD_AUTH" ];
  nativeBuildInputs = [
    curl
    cacert
  ];

  outputHashMode = "flat";
  outputHashAlgo = "sha256";
  outputHash = hash;

  buildCommand = ''
    args=(-fL --retry 3 --retry-delay 2)
    if [[ -n ''${APPLE_ADC_DOWNLOAD_AUTH:-} ]]; then
      args+=(--cookie "ADCDownloadAuth=$APPLE_ADC_DOWNLOAD_AUTH")
    fi
    curl "''${args[@]}" -o "$out" ${lib.escapeShellArg url}
    magic=$(head -c 4 "$out" || true)
    if [[ "$magic" != "xar!" ]]; then
      echo "Apple did not return a package. Export APPLE_ADC_DOWNLOAD_AUTH from an xcodes download session and rebuild with --impure." >&2
      exit 1
    fi
  '';
}
