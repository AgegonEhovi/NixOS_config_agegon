# /etc/nixos/flake.nix
{
  description = "Моя NixOS конфигурация с Flatpak и Home Manager";

  inputs = {
    # Основные Nixpkgs. Можно использовать "nixos-24.05" для stable.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; 

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    # Убедимся, что Home Manager использует ту же версию nixpkgs, что и основная система
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; 
    
    # Nix-Flatpak для декларативной установки Flatpak приложений
    nix-flatpak.url = "github:gmodena/nix-flatpak"; 
    nix-flatpak.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, ... }: {
    # Определяем нашу NixOS конфигурацию
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # Укажи свою архитектуру (x86_64-linux, aarch64-linux и т.д.)
      
      modules = [
        # Твой основной системный конфиг
        ./configuration.nix
        
        # Включаем модуль nix-flatpak
        nix-flatpak.nixosModules.nix-flatpak;
        
        # Включаем Home Manager для пользователя 'agegon' (замени на свое имя пользователя)
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true; # Home Manager будет видеть системные пакеты
          home-manager.useUserPackages = true; # Home Manager будет управлять пользовательскими пакетами
          home-manager.users.agegon = import ./home.nix; # Подключаем файл home.nix для пользователя
        }
      ];
    };
  };
}