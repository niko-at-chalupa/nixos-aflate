{ config, lib, pkgs, ... }:

let
  # Lives outside the repo and outside /nix/store (which is world-readable).
  # Edit it by hand whenever the YouTube Music cookie expires; no rebuild needed.
  secretFile = "${config.home.homeDirectory}/.local/secrets/ytermusic-headers.txt";
in
{
  home.packages = [ pkgs.ytermusic ];

  # ~/.config is managed by home-manager, so ytermusic's headers.txt is a symlink
  # to the writable secret file above. Only the path is tracked here, never the cookie.
  xdg.configFile."ytermusic/headers.txt".source =
    config.lib.file.mkOutOfStoreSymlink secretFile;

  # Make sure the target exists (empty, 0600) so the symlink never dangles.
  # An existing file is left untouched.
  home.activation.ytermusicSecretFile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -d -m 700 "$(dirname "${secretFile}")"
    if [ ! -e "${secretFile}" ]; then
      run install -m 600 /dev/null "${secretFile}"
    fi
  '';
}
