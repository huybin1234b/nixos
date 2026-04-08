# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    inputs.fcitx5-lotus.nixosModules.fcitx5-lotus
  ];

  # Enable Home-manager
  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };
    users = {
      "huybin1234b" = import ./home.nix;
    };
  };

  # Navidome Sever setuo
  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/home/huybin1234b/data/music";
      LogLevel = "debug";
    };
  };
  # disable protect home for navidrome
  systemd.services.navidrome.serviceConfig.ProtectHome = lib.mkForce "tmpfs";
  # environment varible
  environment.variables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    SDL_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  # Set Automated Gabage collection
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
    randomizedDelaySec = "45min";
    persistent = true;
  };

  # Enforce user role and end the pain of the git
  systemd.tmpfiles.rules = [
    "d /etc/nixos 0755 huybin1234b users -"
    "Z /etc/nixos - huybin1234b users -"
  ];
  # Set automatic update | Rebuild
  system.autoUpgrade = {
    enable = true;
    operation = "switch"; # or "boot" to reboot later
    dates = "daily"; # or "04:40" for specific time
    flake = "/etc/nixos/flake.nix"; # optional, for flake users
    allowReboot = false; # reboot if kernel/modules changed
    randomizedDelaySec = "1h"; # optional delay to avoid thundering herd
    persistent = true;
  };
  # === Fcitx5-lotus (now correctly imported via flake) ===
  services.fcitx5-lotus = {
    enable = true;
    user = "huybin1234b";
  };
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };
  # Mounting for data and windows partition
  fileSystems."/home/huybin1234b/data" = {
    device = "/dev/disk/by-uuid/8dd4575c-9bcd-b06f-92f0-1fe360232b87";
    fsType = "btrfs";
    options = [
      "nofail"
      "user"
    ];
  };

  fileSystems."/home/huybin1234b/windows" = {
    device = "/dev/disk/by-uuid/565A603B5A601A4F";
    fsType = "ntfs-3g";
    options = [
      "nofail"
      "user"
      "uid=1000"
    ];
  };

  # Enable OpenTabletDriver
  hardware.opentabletdriver.enable = true;

  # Required by OpenTabletDriver
  hardware.uinput.enable = true;
  boot.kernelModules = [ "uinput" ];
  hardware.opentabletdriver.daemon.enable = true;
  # Flakes + Home Manager support
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Disable systemd-boot
  boot.loader.systemd-boot.enable = false;

  # Base EFI settings
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };

  # Bootloader setup for Limine
  boot.loader.limine = {
    enable = true;
    efiSupport = true;
    enableEditor = true;
    maxGenerations = 30;
    efiInstallAsRemovable = false;

    # Windows dual-boot entry pointing to nvme0n1p5
    extraEntries = ''
      /Windows
          protocol: efi
          path: guid(78d576b7-bf19-4375-b3c3-1e508ff3315a):/EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "huybin1234b-vivobook"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN";
    LC_IDENTIFICATION = "vi_VN";
    LC_MEASUREMENT = "vi_VN";
    LC_MONETARY = "vi_VN";
    LC_NAME = "vi_VN";
    LC_NUMERIC = "vi_VN";
    LC_PAPER = "vi_VN";
    LC_TELEPHONE = "vi_VN";
    LC_TIME = "vi_VN";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.huybin1234b = {
    isNormalUser = true;
    description = "huybin1234b";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };

  # Enable Fish shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  programs.command-not-found.enable = false;

  # Install firefox.
  programs.firefox.enable = true;
  # Install alarm clock
  programs.kclock.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # nix-flatpak thing
  services.flatpak = {
    enable = true;
    uninstallUnmanaged = true; # 1. Fixed option name
    uninstallUnused = true;

    # 2. Update options must be nested inside 'update'
    update = {
      onActivation = true;
      auto = {
        # 3. Changed [ ] to { }
        enable = true;
        onCalendar = "daily"; # 4. Fixed spelling
      };
    };

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      } # 5. Removed the semicolon here!
      {
        name = "flathub-beta";
        location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      } # 5. Removed the semicolon here!
    ];

    packages = [
      {
        appId = "org.nickvision.tubeconverter";
        origin = "flathub";
      } # 6. Fixed appID to appId
      {
        appId = "io.github.diegoivanme.flowtime";
        origin = "flathub";
      }
      {
        appId = "it.mijorus.gearlever";
        origin = "flathub";
      }
      {
        appId = "com.usebottles.bottles";
        origin = "flathub";
      }
      {
        appId = "com.vysp3r.ProtonPlus";
        origin = "flathub";
      }
      # To local install
      #{
      #  appId = "com.custom.MyApp";
      #  bundle = "file:///home/user/custom-app.flatpak";
      #  sha256 = "sha256-1234567890abcdef...";
      #}

      # Flatpak ref *like there is a fucking people that use this?*
      # { flatpakref = "https://example.com/app.flatpakref"; sha256 = "sha256-fedcba0987654321..."; }
    ];
  };

  # Enable NUR
  nixpkgs.overlays = [ inputs.nur.overlays.default ];

  # They doing anything but give us great flatpak and appimage support:/
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    floorp-bin
    neovim
    vimPlugins.LazyVim
    brave
    opentabletdriver
    ente-auth
    vesktop
    osu-lazer-bin
    xournalpp
    zed-editor
    gparted
    tailscale
    ktailctl
    navidrome
    aonsoku
    tauon
    ntfs3g
    zoxide
    bun
    nodejs_25
    vimPlugins.vim-wakatime
    wakatime-cli
    onlyoffice-desktopeditors
    libreoffice-fresh
    fcitx5-mozc
    fcitx5-gtk
    fcitx5-bamboo
    kdePackages.fcitx5-configtool
    ghostty
    obsidian
    anki-bin
    git
    gh
    cobang
    inputs.freesmlauncher.packages.${pkgs.system}.default
    inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.forkprince.helium-nightly
    inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.forkprince.fluxer-bin
    yt-dlp
    haruna
    nixfmt
    nixfmt-tree
    krita
    navidrome
    eloquent
    lmstudio
    python315
    limine-full
    niv
    nh

  ];

  # Default browser
  xdg.mime.defaultApplications = {
    "text/html" = "floorp.desktop";
    "x-scheme-handler/http" = "floorp.desktop";
    "x-scheme-handler/https" = "floorp.desktop";
    "x-scheme-handler/about" = "floorp.desktop";
    "x-scheme-handler/unknown" = "floorp.desktop";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
