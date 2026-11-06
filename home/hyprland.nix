{ config, lib, pkgs, ... }:

let
  hyprlandLua = "${config.home.homeDirectory}/nixos-aflate/dotfiles/config/hypr/hyprland.lua";
  watchHyprlandLua = pkgs.writeShellScript "watch-hyprland-lua" ''
    set -euo pipefail
    ${pkgs.inotify-tools}/bin/inotifywait \
      --monitor \
      --quiet \
      --event close_write \
      --event moved_to \
      --include '(^|/)hyprland\.lua$' \
      --format '%f' \
      ${lib.escapeShellArg (builtins.dirOf hyprlandLua)} |
      while IFS= read -r _; do
        ${pkgs.hyprland}/bin/hyprctl reload
      done
  '';
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    systemd.enable = true;

    # Use nixpkgs' cached Hyprland/xdg-desktop-portal-hyprland instead of the
    # flake's git checkouts. The latter compile the whole Hyprland stack from
    # source, which exceeds this machine's 4 GiB of RAM.
  };

  systemd.user.services.hyprland-lua-reload = {
    Unit = {
      Description = "Reload Hyprland Lua config when it changes";
      PartOf = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStart = watchHyprlandLua;
      Restart = "on-failure";
      RestartSec = "1s";
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  home.file."Pictures/Wallpapers/default.png".source =
    pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${config.home.homeDirectory}/Pictures/Wallpapers/combined.png" ];
      wallpaper = [
        {
          monitor = "eDP-1";
          path = "${config.home.homeDirectory}/Pictures/Wallpapers/combined.png";
        }
      ];
      splash = false;
    };
  };

  home.sessionVariables = {
    HYPRCURSOR_THEME = "BreezX-RosePine-Linux";
    HYPRCURSOR_SIZE = "24";
  };
}
