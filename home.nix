{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./home/dotfiles.nix
    ./home/hyprland.nix
    ./home/packages.nix
    ./home/vscode.nix
    ./home/zsh.nix
  ];
  home.username = "niko";
  home.homeDirectory = "/home/niko";
  home.stateVersion = "26.05";
  home.enableNixpkgsReleaseCheck = false;
}
