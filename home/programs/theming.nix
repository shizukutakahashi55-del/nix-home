{ pkgs, lib, ... }:

{
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  gtk = {
    enable = true;

    theme = {
      name = lib.mkForce "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };

  home.packages = with pkgs; [
    qt6Packages.qt6ct
    matugen
    nwg-look

     # Icons
    #tela-icon-theme
    papirus-icon-theme
    kdePackages.breeze-icons

    kdePackages.qt6ct

    # Qt styles
    kdePackages.breeze
    adwaita-qt6
    qt6Packages.qtstyleplugin-kvantum

    #Installer
  ];
}
