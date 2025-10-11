{
  description = "my zmk config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    zephyr.url = "github:zmkfirmware/zephyr/v3.5.0+zmk-fixes";
    zephyr.flake = false;

    zephyr-nix.url = "github:nix-community/zephyr-nix";
    zephyr-nix.inputs.zephyr.follows = "zephyr";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { flake-parts, zephyr-nix, ... }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["aarch64-darwin"];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        zephyr = zephyr-nix.packages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            zephyr.pythonEnv
            (zephyr.sdk-0_16.override { targets = ["arm-zephyr-eabi"]; })

            # zephyr.hosttools
            pkgs.cmake
            pkgs.dtc
            pkgs.ninja
            pkgs.qemu

            pkgs.just
            pkgs.yq
            pkgs.remarshal
            pkgs.ccache

            pkgs.keymap-drawer
          ];
          env = {
            # ZEPHYR_TOOLCHAIN_VARIANT = "gnuarmemb";
            # GNUARMEMB_TOOLCHAIN_PATH = pkgs.gcc-arm-embedded;
          };
        };
      };
    };
}
