{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    systemd.enable = true;

    # Use nixpkgs' cached Hyprland/xdg-desktop-portal-hyprland instead of the
    # flake's git checkouts. The latter compile the whole Hyprland stack from
    # source, which exceeds this machine's 4 GiB of RAM.
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
