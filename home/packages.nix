{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.kdeconnect-kde
    # yaak is not prebuilt in nixpkgs; compiling this Tauri/Rust app needs far
    # more than 4 GiB. Use the upstream release/Flatpak instead.
    # yaak
    copyq
    arrpc
    brightnessctl
    fuzzel
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    hyprshot
    vscode
    nodejs
    pnpm
    yarn
    python3
    pyright
    ruff
    ty
    uv
    ripgrep
    nixfmt
    ouch
    unzip
    ffmpeg
    deno
    zsh-powerlevel10k
    lutris
    protontricks
    hyprpicker
    openutau
    inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.helium
  ];
}
