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

      gbToolsEnabled = let
        flagFile = self + "/.gbtools";
      in
        builtins.pathExists flagFile && builtins.readFile flagFile != "";

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
          wrapProgram $out/bin/lcc --set GBDKDIR "$out/"
        '';
      };

      gb-tools =
        if gbToolsEnabled && pkgs.stdenv.isLinux
        then let
          gbtd-src = pkgs.fetchzip {
            name = "gbtd";
            url = "https://www.devrs.com/gb/hmgd/gbtd22.zip";
            sha256 = "sha256-UFvGgSN9clPW68WvVUadM63uvJeJCvGoWKFyI+/yOc8=";
            stripRoot = false;
          };

          gbmb-src = pkgs.fetchzip {
            name = "gbmb";
            url = "https://www.devrs.com/gb/hmgd/gbmb18.zip";
            sha256 = "sha256-tS14jkRHMg0yLyEi/RyYNcRZqjHk3mANosI+ZvFmwAM=";
            stripRoot = false;
          };
        in
          pkgs.stdenvNoCC.mkDerivation {
            pname = "gbtd-gbmb";
            version = "unstable";

            srcs = [gbtd-src gbmb-src];
            sourceRoot = ".";

            nativeBuildInputs = [pkgs.makeWrapper pkgs.unzip];

            unpackPhase = ''
              mkdir -p gbtd gbmb
              cp -r ${gbtd-src}/* gbtd/
              cp -r ${gbmb-src}/* gbmb/
            '';

            installPhase = ''
              mkdir -p $out/share/gb-tools/gbtd
              mkdir -p $out/share/gb-tools/gbmb

              cp -r gbtd/* $out/share/gb-tools/gbtd/
              cp -r gbmb/* $out/share/gb-tools/gbmb/

              mkdir -p $out/bin

              makeWrapper ${pkgs.wine-wayland}/bin/wine $out/bin/gbtd \
                --add-flags "$out/share/gb-tools/gbtd/gbtd.exe"

              makeWrapper ${pkgs.wine-wayland}/bin/wine $out/bin/gbmb \
                --add-flags "$out/share/gb-tools/gbmb/gbmb.exe"
            '';
          }
        else null;
    in {
      packages.default =
        if gb-tools != null
        then gb-tools
        else pkgs.emptyDirectory;

      devShells.default = pkgs.mkShell {
        buildInputs =
          pkgs.lib.optional (gb-tools != null) gb-tools
          ++ pkgs.lib.optional (gb-tools != null) pkgs.wine-wayland;

        packages = [
          gbdk
          pkgs.clang-tools
          pkgs.gnumake
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
