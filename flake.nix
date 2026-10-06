{
  description = "Nix packages for Apple developer tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [ "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          fetchApple = pkgs.callPackage ./pkgs/fetch-apple.nix { };
          pass-designer = pkgs.callPackage ./pkgs/pass-designer {
            inherit fetchApple;
          };
        in
        {
          inherit pass-designer;
          default = pass-designer;
        }
      );

      darwinModules.default = ./modules/darwin.nix;
      darwinModules.pass-designer = ./modules/darwin.nix;
    };
}
