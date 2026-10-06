{
  lib,
  pkgs,
  ...
}:
let
  pass-designer = pkgs.callPackage ../pkgs/pass-designer {
    fetchApple = pkgs.callPackage ../pkgs/fetch-apple.nix { };
  };
  app = "${pass-designer}/Applications/Pass Designer.app";
in
lib.mkIf pkgs.stdenv.isDarwin {
  environment.systemPackages = [ pass-designer ];

  system.activationScripts.pass-designer.text = ''
    target="/Applications/Pass Designer.app"
    source=${lib.escapeShellArg app}
    if [ -L "$target" ] || [ ! -e "$target" ]; then
      ln -sfn "$source" "$target"
    else
      echo "Pass Designer.app is already installed outside Nix; leaving it in place"
    fi
  '';
}
