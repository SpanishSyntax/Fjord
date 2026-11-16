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

    nixosModules.default = { config, lib, pkgs, ... }:
      with lib;
      let
        pkg = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        cfg = config.programs.fjord;
      in {
        options.programs.fjord = {
          enable = mkEnableOption "Fjord (Wormhole) Material 3 Expressive XDG Desktop Portal integration";
          package = mkOption {
            type = types.package;
            default = pkg;
            description = "The fjord / wormhole package to use.";
          };
        };

        config = mkIf cfg.enable {
          environment.systemPackages = [ cfg.package ];

          xdg.portal = {
            enable = true;
            extraPortals = [ cfg.package ];
            config = {
              common.default = mkDefault [ "wormhole" "hyprland" "gtk" ];
              hyprland = {
                default = mkDefault [ "wormhole" "hyprland" "gtk" ];
                "org.freedesktop.impl.portal.ScreenCast" = mkDefault "wormhole";
                "org.freedesktop.impl.portal.Screenshot" = mkDefault "wormhole";
                "org.freedesktop.impl.portal.FileChooser" = mkDefault "wormhole";
                "org.freedesktop.impl.portal.AppChooser" = mkDefault "wormhole";
                "org.freedesktop.impl.portal.Access" = mkDefault "wormhole";
                "org.freedesktop.impl.portal.DynamicLauncher" = mkDefault "wormhole";
                "org.freedesktop.impl.portal.Wallpaper" = mkDefault "wormhole";
              };
            };
          };
        };
      };
    nixosModules.fjord = self.nixosModules.default;

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
          daemon = {
            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to start Wormhole daemon with graphical-session.target.";
            };
          };
        };

        options.programs.wormhole = {
          enable = mkEnableOption "Alias for programs.fjord";
          package = mkOption {
            type = types.package;
            default = pkg;
            description = "The fjord / wormhole package to use.";
          };
          daemon = {
            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to start Wormhole daemon with graphical-session.target.";
            };
          };
        };

        config = mkIf enabled {
          home.packages = [ activeCfg.package ];

          xdg.portal = {
            enable = true;
            extraPortals = [ activeCfg.package ];
            config = {
              common.default = [ "wormhole" "hyprland" "gtk" ];
              hyprland = {
                default = [ "wormhole" "hyprland" "gtk" ];
                "org.freedesktop.impl.portal.ScreenCast" = "wormhole";
                "org.freedesktop.impl.portal.Screenshot" = "wormhole";
                "org.freedesktop.impl.portal.FileChooser" = "wormhole";
                "org.freedesktop.impl.portal.AppChooser" = "wormhole";
                "org.freedesktop.impl.portal.Access" = "wormhole";
                "org.freedesktop.impl.portal.DynamicLauncher" = "wormhole";
                "org.freedesktop.impl.portal.Wallpaper" = "wormhole";
              };
            };
          };

          systemd.user.services.xdg-desktop-portal-wormhole = mkIf activeCfg.daemon.enable {
            Unit = {
              Description = "Wormhole Material 3 Desktop Portal";
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "${activeCfg.package}/bin/wormhole --daemon";
              Restart = "on-failure";
              RestartSec = "1s";
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };
        };
      };
  };
}
