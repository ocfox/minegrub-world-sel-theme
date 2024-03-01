{
  description = "minegrub world sel theme nixos module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs;
      eachSystem = f: genAttrs
        [
          "x86_64-linux"
          "aarch64-linux"
        ]
        (system: f nixpkgs.legacyPackages.${system});

      minegrub-world = { pkgs, ... }:
        pkgs.stdenv.mkDerivation {
          name = "minegrub-world-sel-theme";
          src = "${self}";

          installPhase = ''
            mkdir -p $out/grub/themes
            cp -r minegrub-world-selection $out/grub/themes/minegrub-world-sel-theme
          '';
        };
    in
    {
      nixosModules.default = { config, pkgs, ... }:
        let
          cfg = config.boot.loader.grub.minegrub-world-sel-theme;
          inherit (nixpkgs.lib) mkOption types mkIf;
        in
        {
          options = {
            boot.loader.grub.minegrub-world-sel-theme = {
              enable = mkOption {
                default = false;
                example = true;
                type = types.bool;
                description = ''
                  Enable minegrub-world-select theme.
                '';
              };
            };
          };
          config = mkIf cfg.enable {
            boot.loader.grub =
              let
                minegrub-world-sel-theme = minegrub-world { inherit pkgs; };
              in
              {
                theme = "${minegrub-world-sel-theme}/grub/themes/minegrub-world-sel-theme";
                splashImage = "${minegrub-world-sel-theme}/grub/themes/minegrub-world-sel-theme/background.png";
              };
          };
        };
      packages = eachSystem (pkgs: { default = minegrub-world { inherit pkgs; }; });

    };
}
