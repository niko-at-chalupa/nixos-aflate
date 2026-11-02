{ pkgs, lib, ... }:

# Flutter/Dart from the official release archive, pinned by hash.
#
# nixpkgs' flutter package lags the current stable release, so the official SDK
# archive is tracked directly. Only the ~1.5G tarball lives in the Nix store;
# it is unpacked once into `~/.local/share/flutter` because the Flutter tool
# needs to write into `bin/cache`. The copy is refreshed whenever the pinned
# archive changes.
let
  version = "3.47.9";
  dartVersion = "3.13.7"; # bundled with the SDK above

  archive = pkgs.fetchurl {
    url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${version}-stable.tar.xz";
    hash = "sha256-Je2MPCnVGnNT8qlEMQtHivghSSBjlSSxnFChnmwETFo=";
  };

  # GTK/GLib development dependencies used when building Linux desktop apps.
  desktopDeps = with pkgs; [
    atk
    cairo
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    libepoxy
    libx11
    libdeflate
    pango
    xorgproto
    zlib
  ];

  # Transitive dependency closure, mirroring how nixpkgs' own Flutter
  # wrapper assembles its pkg-config and linker search paths.
  desktopClosure =
    let
      deps =
        pkg: lib.filter lib.isDerivation ((pkg.buildInputs or [ ]) ++ (pkg.propagatedBuildInputs or [ ]));
      withKey = pkg: {
        key = pkg.outPath;
        val = pkg;
      };
    in
    lib.map (e: e.val) (
      lib.genericClosure {
        startSet = lib.map withKey desktopDeps;
        operator = item: lib.map withKey ([ item.val ] ++ deps item.val);
      }
    );

  pkgConfigDeps = map (lib.getOutput "dev") desktopClosure;

  # Some packages ship their .pc files in share/pkgconfig (e.g. zlib).
  pkgConfigPath = lib.concatStringsSep ":" [
    (lib.makeSearchPathOutput "dev" "lib/pkgconfig" pkgConfigDeps)
    (lib.makeSearchPathOutput "dev" "share/pkgconfig" pkgConfigDeps)
  ];

  # Headers that the GTK pkg-config files don't pull in, but that GTK's own
  # headers require (mirrors nixpkgs' Flutter wrapper).
  staticBuildDeps = with pkgs; [
    libx11
    xorgproto
    zlib
  ];

  includeFlags = lib.concatMapStringsSep " " (
    p: "-isystem ${lib.getOutput "dev" p}/include"
  ) staticBuildDeps;

  runtimeInputs = with pkgs; [
    bash
    coreutils
    findutils
    gnugrep
    gnused
    gnutar
    util-linux # flock
    xz
    gitMinimal
    which
    curl
    unzip
    pkg-config
    cmake
    ninja
    clang
    gnumake
  ];

  # Ensures the writable SDK copy exists and matches the pinned archive,
  # then prints its location.
  sdkPath = pkgs.writeShellApplication {
    name = "flutter-sdk-path";
    runtimeInputs = with pkgs; [
      bash
      coreutils
      findutils
      gnused
      gnutar
      util-linux
      xz
    ];
    text = ''
      root="''${XDG_DATA_HOME:-$HOME/.local/share}/flutter"
      want=${lib.escapeShellArg "${archive}"}

      stale() {
        [ "$(cat "$root/.nix-store-path" 2>/dev/null || true)" != "$want" ] \
          || [ ! -x "$root/bin/flutter" ]
      }

      # NixOS has no /usr/bin/env, so scripts that are executed directly need
      # a real interpreter baked in.
      fix_shebang() {
        [ -f "$1" ] || return 0
        case "$(head -n 1 "$1")" in
          '#!'*'/usr/bin/env bash'*) sed -i '1s|^#!.*|#!${pkgs.bash}/bin/bash|' "$1" ;;
          '#!'*'/usr/bin/env sh'*) sed -i '1s|^#!.*|#!${pkgs.bash}/bin/sh|' "$1" ;;
        esac
      }

      if stale; then
        mkdir -p "$(dirname "$root")"
        (
          flock 9
          if stale; then
            tmp="$root.nix-tmp"
            chmod -R u+w "$tmp" 2>/dev/null || true
            rm -rf "$tmp"
            mkdir -p "$tmp"
            tar -xJf "$want" -C "$tmp" --strip-components=1

            while IFS= read -r -d "" file; do
              fix_shebang "$file"
            done < <(find "$tmp/bin" "$tmp/packages/flutter_tools/bin" -type f)

            chmod -R u+w "$tmp"
            printf '%s' "$want" > "$tmp/.nix-store-path"
            chmod -R u+w "$root" 2>/dev/null || true
            rm -rf "$root"
            mv "$tmp" "$root"
          fi
        ) 9>"$root.lock"
      fi

      printf '%s\n' "$root"
    '';
  };

  mkLauncher =
    name: binary:
    pkgs.writeShellApplication {
      inherit name;
      inherit runtimeInputs;
      text = ''
        sdk="$(${lib.getExe sdkPath})"
        export PUB_CACHE="''${PUB_CACHE:-$HOME/.pub-cache}"
        export PKG_CONFIG_PATH="${pkgConfigPath}:''${PKG_CONFIG_PATH:-}"
        export LD_LIBRARY_PATH="${lib.makeLibraryPath desktopClosure}:''${LD_LIBRARY_PATH:-}"
        export LIBRARY_PATH="${lib.makeLibraryPath staticBuildDeps}:''${LIBRARY_PATH:-}"
        export CFLAGS="${includeFlags} ''${CFLAGS:-}"
        export CXXFLAGS="${includeFlags} ''${CXXFLAGS:-}"
        export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
        exec "$sdk/bin/${binary}" "$@"
      '';
    };

  flutter = pkgs.symlinkJoin {
    name = "flutter-${version}";
    paths = [
      (mkLauncher "flutter" "flutter")
      (mkLauncher "dart" "dart")
    ];
    meta = {
      description = "Flutter ${version} / Dart ${dartVersion} (official stable SDK)";
      homepage = "https://flutter.dev";
      license = lib.licenses.bsd3;
      platforms = [ "x86_64-linux" ];
      mainProgram = "flutter";
    };
  };
in
{
  home.packages = [ flutter ];
}
