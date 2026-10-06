# nix-apple-tools

Nix packages for Apple developer tools that are not in Nixpkgs.

## Pass Designer

Pass Designer 1.0 beta 2 is the Mac app for designing Apple Wallet passes. The installer is hosted on Apple's developer download site and requires an `ADCDownloadAuth` cookie from a signed-in Xcode or `xcodes` session.

The Nix daemon does not forward that cookie into the download sandbox. Download the pkg with the cookie, then register the file by hash. The package name and hash are fixed, so this only has to happen once per machine:

```sh
curl -fL --cookie "ADCDownloadAuth=$APPLE_ADC_DOWNLOAD_AUTH" \
  -o Pass_Designer_beta2.pkg \
  https://download.developer.apple.com/Developer_Tools/Pass_Designer_beta/Pass_Designer_beta2.pkg
nix-store --add-fixed sha256 Pass_Designer_beta2.pkg
nix build .#pass-designer
```

The package is `aarch64-darwin` only and needs macOS 27 or later. The app is installed to `$out/Applications/Pass Designer.app`.

## nix-darwin

```nix
{
  inputs.nix-apple-tools.url = "github:JudahZF/nix-apple-tools";

  outputs = { nix-darwin, nix-apple-tools, ... }: {
    darwinConfigurations.my-mac = nix-darwin.lib.darwinSystem {
      modules = [ nix-apple-tools.darwinModules.default ];
    };
  };
}
```

The module adds the package and symlinks it to `/Applications/Pass Designer.app` when that path is missing or already a symlink. Register `Pass_Designer_beta2.pkg` with `nix-store --add-fixed` before the first rebuild.
