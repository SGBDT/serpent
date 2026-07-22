{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      serpent = pkgs.stdenv.mkDerivation {
        pname = "serpent";
        version = "0.1.0";

        src = ./.;

        nativeBuildInputs = [
          gbdk
        ];

        buildPhase = ''
          export GBDK_HOME=${gbdk}
          export PATH=$GBDK_HOME/bin:$PATH
          make
        '';

        installPhase = ''
          mkdir -p $out
          cp build/serpent.gb $out/
        '';
      };

      gbdk = pkgs.stdenv.mkDerivation {
        pname = "gbdk";
        version = "4.5.0";

        src = pkgs.fetchzip {
          url = "https://github.com/gbdk-2020/gbdk-2020/releases/download/4.5.0/gbdk-linux64.tar.gz";
          hash = "sha256-SeLoKHRAAq+3xVog8kBV9hj2wrQ24JvOQml3A8p1Yyg=";
        };

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
          makeWrapper
        ];

        buildInputs = with pkgs; [
          stdenv.cc.cc.lib
          zlib
        ];

        installPhase = ''
          mkdir -p $out
          cp -r . $out

          wrapProgram $out/bin/lcc \
            --set GBDKDIR "$out/"
        '';
      };

      gbtd-gbmb-src = pkgs.fetchzip {
        name = "gbtd-gbmb";
        url = "https://github.com/gbdk-2020/GBTD_GBMB/releases/download/2.4.5/GBTD_GBMB_release.zip";
        sha256 = "sha256-zLb5y4DnrYoGmOqr+oc4Id60O3CdF2Xx5qKzy9BeBYM=";
        stripRoot = false;
      };

      gb-tools = pkgs.stdenvNoCC.mkDerivation {
        pname = "gbtd-gbmb";
        version = "2.4.5";

        src = gbtd-gbmb-src;

        nativeBuildInputs = [pkgs.makeWrapper];

        installPhase = ''
          mkdir -p $out/share/gb-tools/gbtd $out/share/gb-tools/gbmb

          cp -r GBTD/* $out/share/gb-tools/gbtd/
          cp -r GBMB/* $out/share/gb-tools/gbmb/

          mkdir -p $out/bin

          makeWrapper ${pkgs.wine-wayland}/bin/wine $out/bin/gbtd \
            --add-flags "$out/share/gb-tools/gbtd/gbtd.exe"

          makeWrapper ${pkgs.wine-wayland}/bin/wine $out/bin/gbmb \
            --add-flags "$out/share/gb-tools/gbmb/gbmb.exe"
        '';
      };
    in {
      packages = {
        default = serpent;
        gbdk = gbdk;
        gb-tools = gb-tools;
      };

      apps.default = {
        type = "app";
        program = "${pkgs.writeShellScript "run-serpent" ''
          exec ${pkgs.gearboy}/bin/gearboy ${serpent}/serpent.gb
        ''}";
      };

      devShells.default = pkgs.mkShell {
        buildInputs = [
          gb-tools
          pkgs.wine-wayland
        ];

        packages = [
          gbdk
          pkgs.clang-tools
          pkgs.gnumake
          pkgs.mbake
          pkgs.gearboy
          pkgs.bear
        ];

        shellHook = ''
          export GBDK_HOME=${gbdk}
          export PATH=$GBDK_HOME/bin:$PATH
        '';
      };
    });
}
