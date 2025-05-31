# /etc/nixos/home.nix
{ config, pkgs, ... }:

{
  # Это домашняя директория твоего пользователя
  home.homeDirectory = "/home/agegon";

  # Nixpkgs для Home Manager (должен совпадать с flake.nix)
  home.stateVersion = "24.11"; # Используй ту же версию, что и в system.stateVersion

  # Здесь ты можешь определить пакеты, которые будут установлены только для твоего пользователя
  home.packages = with pkgs; [
    telegram-desktop
    helvum
    kitty
    hiddify-app
    keepassxc
    brave    
    firefox
    vscode
    # Если podman и distrobox не нужны системно, перенеси их сюда:
    # podman
    # distrobox
  ];

  # Пример настройки GNOME-терминала через Home Manager (для демонстрации)
  # Если ты хочешь управлять dotfiles, это отличное место для этого.
  # dconf.settings = {
  #   "org/gnome/Terminal/Legacy/Profile/:b1dcc830-4e31-4824-a6ff-59b0997e6b8b" = {
  #     palette = "['#000000', '#CC0000', '#4E9A06', '#C4A000', '#3465A4', '#75507B', '#06989A', '#D3D7CF', '#555753', '#EF2929', '#8AE234', '#FCE94F', '#729FCF', '#AD7FA8', '#34E2E2', '#EEEEEC']";
  #     use-theme-colors = false;
  #   };
  # };

  # Можешь добавить больше конфигураций Home Manager здесь:
  # programs.bash.enable = true;
  # programs.zsh.enable = true;
  # git.enable = true;
  # ... и т.д.
}