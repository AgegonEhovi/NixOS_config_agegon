{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NVIDIA optimization: Enable DRM kernel mode setting for better graphics performance
  boot.kernelParams = [ "nvidia-drm.modeset=1" "amd_iommu=on" ]; # Enable IOMMU for GPU passthrough

  # Enable KVM for AMD processors
  boot.kernelModules = [ "kvm-amd" "kvm" "vfio" "vfio_iommu_type1" "vfio_pci" ]; # Load KVM and VFIO modules for virtualization
  boot.extraModprobeConfig = ''
    options kvm-amd nested=1
    options kvm ignore_msrs=1
  '';

  networking.hostName = "nixos";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "ru_RU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Add NVIDIA driver support
  services.xserver.videoDrivers = [ "nvidia" ];
  # Optional: Force Wayland (GNOME default), but NVIDIA support might be shaky. Set to false for X11 if lag persists.
  services.xserver.displayManager.gdm.wayland = true;

  # NVIDIA configuration
  hardware.nvidia = {
    open = false; # true = use open-source NVIDIA drivers (recommended for Turing GPUs and newer, e.g., RTX, GTX 16xx)
    # Set to `false` for older GPUs (e.g., GTX 10xx or earlier) if you experience issues
    nvidiaSettings = true; # Enable nvidia-settings utility
    modesetting.enable = true; # Required for Wayland and better performance
    powerManagement.enable = true; # Enable power management for NVIDIA GPUs
    package = config.boot.kernelPackages.nvidiaPackages.stable; # Stable proprietary driver
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "ru";
    variant = "";
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
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

  # Enable Flatpak
  services.flatpak.enable = true;

  # Добавляем Flathub через system-wide конфигурацию
  system.activationScripts.flatpak-repo = ''
    ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo'';

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.agegon = {
    isNormalUser = true;
    description = "Agegon";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "agegon";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";  # Run garbage collection weekly
    options = "--delete-older-than 10d";  # Delete generations older than 10 days
  };

  #Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Для Steam Remote Play
    dedicatedServer.openFirewall = true; # Для серверов
  };

  # Enable libvirt and QEMU/KVM for virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm; # Use QEMU with KVM support
      runAsRoot = true; # Run QEMU as root for full hardware access
      swtpm.enable = true; # Enable TPM emulation
      ovmf.enable = true; # Enable OVMF for UEFI support
    };
  };

  # Enable Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; 
  };

  # Enable SPICE for USB redirection in VMs
  virtualisation.spiceUSBRedirection.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    telegram-desktop
    helvum
    kitty
    hiddify-app
    keepassxc
    brave     
    htop
    neofetch
    gnome-terminal
    python3
    vscode
    virt-manager
    libvirt
    qemu 
    qemu_kvm
    spice 
    spice-gtk
    firefox
    lf
    distrobox
    anki-bin
    obsidian
  ];

  # Fonts for better text rendering
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
  ];

  # USB automount for convenience in GNOME
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Enable firmware updates
  hardware.enableAllFirmware = true;

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
  system.stateVersion = "24.11"; # Did you read the comment?

}