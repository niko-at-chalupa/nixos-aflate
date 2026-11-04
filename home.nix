{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./home/dotfiles.nix
    ./home/fuzzel.nix
    ./home/hyprland.nix
    ./home/notifications.nix
    ./home/packages.nix
    ./home/vscode.nix
    ./home/zsh.nix
  ];
  home.username = "niko";
  home.homeDirectory = "/home/niko";
  home.stateVersion = "26.05";
  home.enableNixpkgsReleaseCheck = false;
  home.sessionVariables.GH_CONFIG_DIR = "${config.home.homeDirectory}/.local/share/gh";
}
