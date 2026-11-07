# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Never autosuspend USB devices; the Wi-Fi dongle goes flaky when it sleeps.
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  networking.hostName = "aflate"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Wi-Fi power saving causes dropped frames and DHCP timeouts on the USB
  # adapter, so turn it off entirely.
  networking.networkmanager.wifi.powersave = false;

  # Declare the home Wi-Fi profile instead of creating it by hand in nmtui.
  # It is deliberately not pinned to an interface name: the USB dongle's name
  # changes with the port it is plugged into, and a pinned profile stops
  # matching, so nmtui creates a duplicate ("11:11 1", "11:11 2", ...).
  #
  # The password lives outside the repo. Create it once with:
  #   sudo install -d -m 700 /var/lib/secrets
  #   echo 'WIFI_PSK=yourpassword' | sudo tee /var/lib/secrets/wifi.env
  #   sudo chmod 600 /var/lib/secrets/wifi.env
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ "/var/lib/secrets/wifi.env" ];
    profiles.home-wifi = {
      connection = {
        id = "11:11";
        uuid = "9e9b0e0c-5a98-4048-afee-c5e875cb49ab";
        type = "wifi";
        autoconnect = "true";
      };
      wifi = {
        ssid = "11:11";
        mode = "infrastructure";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$WIFI_PSK";
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Set your time zone.
  time.timeZone = "Asia/Manilla";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = false;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  security.rtkit.enable = true;
  services.pipewire = {
     enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
     pulse.enable = true;
     wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.niko = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "networkmanager"
      "video"
      "input"
    ];
    packages = with pkgs; [
      tree
    ];
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim
    wget
    vim
    helix
    git
    zsh
    jq
    ghostty
    kdePackages.breeze
    kdePackages.qqc2-desktop-style
    kdePackages.kirigami
    kdePackages.breeze-icons
    kdePackages.kservice
    wl-clipboard
    cliphist
    rustup
    cargo
    rustc
    rustPlatform.rustcSrc
    rust-analyzer
    rustfmt
    clippy
    gcc
    gh
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # This machine only has 4 GiB of RAM. Keep builds serial and limit each
  # derivation to one compiler job so a single build cannot exhaust memory.
  nix.settings.max-jobs = 1;
  nix.settings.cores = 1;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  hardware.graphics.enable = true;

  services.flatpak.enable = true;
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;

  qt = {
    enable = true;
    platformTheme = "kde";
    style = "breeze";
  };

  nixpkgs.config.problems.handlers = {
    "gtk+".broken = "warn";
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.gnome.at-spi2-core.enable = true;
  security.polkit.enable = true;
  security.soteria.enable = true;
  security.pam.services.niko.kwallet = {
    enable = true;
    package = pkgs.kdePackages.kwallet-pam;
  };

  services.keyd = {
    enable = true;
    keyboards.macbook = {
      ids = [ "05ac:0290:f2d1f5c2" ];
      settings.main = {
        fn = "leftcontrol";
        leftcontrol = "fn";
        capslock = "esc";
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs.git = {
    enable = true;
    config = {
      user = {
        name = "niko-at-chalupa";
        email = "nikolekrescendo@protonmail.com";
      };
      init = {
        defaultBranch = "main";
      };
      safe = {
        directory = "/etc/nixos";
      };
    };
  };

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  
  programs.nix-ld.enable = true;

  fonts.packages = [
    pkgs.meslo-lgs-nf
    (pkgs.google-fonts.override {
      fonts = [ "XanhMono" "RobotoMono" ];
    })
  ];
  fonts.fontDir.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPortRanges = [
    { from = 1714; to = 1764; }
  ];

  networking.firewall.allowedUDPPortRanges = [
    { from = 1714; to = 1764; }
  ];

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib   # libstdc++.so.6
    llvmPackages_21.libcxx # libc++.so.1
    llvmPackages_21.libunwind # libunwind.so.1
    libxkbcommon        # libxkbcommon.so.0
    udev                # libudev.so.1 — actually provided by `systemd` on NixOS
    libinput             # libinput.so.10
    libgbm                 # libgbm.so.1
    fontconfig          # libfontconfig.so.1
    freetype             # libfreetype.so.6
    ncurses5             # libncurses.so.5 and libtinfo.so.5 for older Lua tools
    wayland
  ];
}
