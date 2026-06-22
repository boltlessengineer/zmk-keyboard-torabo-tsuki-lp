{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    paw3222 = {
      url = "path:///Users/boltless/repo/zmk-driver-paw3222";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, zmk-nix, paw3222 }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: rec {
      default = firmware;

      firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "firmware";

        src = nixpkgs.lib.sourceFilesBySuffices self [ ".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi" ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig"
          # to use source as zmk module
          ".c" ".h" ".txt" ];

        board = "bmp_boost";
        shield = "torabo_tsuki_lp_%PART%";
        # enableZmkStudio = true;
        snippets = ["studio-rpc-usb-uart"]; # explicitly set studio-rpc-usb-uart instead of enableZmkStudio so it is configured for both left and right side of the board.
        parts = [
          "left"
          "right"
        ];
        centralPart = "right"; # not used since we aren't using enableZmkStudio
        extraWestBuildFlags = [ ];
        extraCmakeFlags = [
          "-DZMK_EXTRA_MODULES=${paw3222}"
        ];

        zephyrDepsHash = "sha256-0qMlYPRXLVlp5m0dao2A+4prbiAVLuNFElMderMXrII=";

        meta = {
          description = "ZMK firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
