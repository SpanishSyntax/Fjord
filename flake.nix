{
  description = "Fjord - Material 3 Expressive XDG Desktop Portal daemon & dialogs for Wayland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    forAllSystems = fn:
      nixpkgs.lib.genAttrs nixpkgs.lib.platforms.linux (
        system: fn nixpkgs.legacyPackages.${system}
      );
  in {
    packages = forAllSystems (pkgs: rec {
      fjord = pkgs.callPackage ./nix {};
      wormhole = fjord;
      default = fjord;
    });

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          cmake
          ninja
          pkg-config
          wayland-scanner
          wayland-protocols
          pipewire
          glib
          qt6.qtbase
          qt6.qtdeclarative
          qt6.qtsvg
          qt6.qtmultimedia
          qt6.wrapQtAppsHook
          grim
        ];
      };
    });

    homeManagerModules.default = { config, lib, pkgs, ... }:
      with lib;
      let
        pkg = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        fjordCfg = config.programs.fjord;
        wormholeCfg = config.programs.wormhole;
        enabled = fjordCfg.enable || wormholeCfg.enable;
        activeCfg = if fjordCfg.enable then fjordCfg else wormholeCfg;
      in {
        options.programs.fjord = {
          enable = mkEnableOption "Fjord Material 3 Expressive XDG Desktop Portal daemon";
          package = mkOption {
            type = types.package;
            default = pkg;
            description = "The fjord / wormhole package to use.";
          };
        };

        options.programs.wormhole = {
          enable = mkEnableOption "Alias for programs.fjord";
          package = mkOption {
            type = types.package;
            default = pkg;
            description = "The fjord / wormhole package to use.";
          };
        };

        config = mkIf enabled {
          home.packages = [ activeCfg.package ];
        };
      };
  };
}
