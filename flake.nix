{
  description = "NixOS configuration";

  inputs = {
    # ==========================================================================
    # NIXPKGS
    # ==========================================================================
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Añadimos una segunda entrada para la versión inestable
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # ==========================================================================
    # MILLENNIUM
    # ==========================================================================
    # millennium.url =
    #   "github:SteamClientHomebrew/Millennium?dir=packages/nix";

    # ==========================================================================
    # PRISM LAUNCHER
    # ==========================================================================
    prismlauncher = {
      url = "github:PrismLauncher/PrismLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ==========================================================================
    # Sonora
    # ==========================================================================
    sonora.url = "github:sonorahq/sonora";

    # ==========================================================================
    # HYPRLAND
    # ==========================================================================
    hyprland.url = "github:hyprwm/Hyprland";

    # amane.url = "github:MystiaFin/amane";

    # ==========================================================================
    # HOME MANAGER
    # ==========================================================================
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ==========================================================================
    # QUICKSHELL
    # ==========================================================================
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ==========================================================================
    # MANGOWM
    # ==========================================================================

    #  mangowm = {
    #    url = "github:mangowm/mango";
    #    inputs.nixpkgs.follows = "nixpkgs-unstable";
    #  };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        # Pasamos nixpkgs-unstable para poder usarlo en otros archivos
        pkgsUnstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      };

      modules = [
        #{
        #  nixpkgs.hostPlatform = "x86_64-linux";
        #  nixpkgs.overlays = [
        #    inputs.millennium.overlays.default
        #  ];
        #}
        inputs.home-manager.nixosModules.home-manager
        ./configuration.nix
      ];
    };
  };
}
