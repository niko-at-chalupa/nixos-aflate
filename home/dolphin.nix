{ pkgs, ... }:

{
  # Keep one Dolphin process resident (no window) so opening a window is a D-Bus
  # call into a warm process instead of a cold Qt/KF6 start. It registers
  # org.freedesktop.FileManager1, which the Super+E bind in hyprland.lua uses.
  #
  # Only runs inside a graphical session: it is wanted by graphical-session.target
  # (which hyprland-session.target pulls in once Hyprland has started) and is
  # skipped unless WAYLAND_DISPLAY was imported into the systemd user manager.
  systemd.user.services.dolphin-daemon = {
    Unit = {
      Description = "Dolphin file manager (resident, no window)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      ExecStart = "${pkgs.kdePackages.dolphin}/bin/dolphin --daemon";
      # hyprland.lua sets these with hl.env, which systemd user services don't
      # inherit, so repeat them or Dolphin comes up unthemed.
      Environment = [
        "QT_QPA_PLATFORMTHEME=kde"
        "QT_STYLE_OVERRIDE=kvantum"
      ];
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
