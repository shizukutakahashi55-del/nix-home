{ pkgs, ... }:

{

      # Dolphin: application menu outside KDE Plasma
  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  # Paquetes de sistema
  environment.systemPackages = with pkgs; [
    # File manager
    kdePackages.dolphin
    kdePackages.dolphin-plugins

    # Archives
    kdePackages.ark

    # Dolphin previews / thumbnails
    kdePackages.kdegraphics-thumbnailers
    kdePackages.ffmpegthumbs

    # Extras recomendados para Dolphin en KDE
    kdePackages.qtimageformats   # formatos de imagen extra (webp, etc.)
    kdePackages.poppler          # miniaturas de PDF
    kdePackages.kio-extras       # protocolos adicionales (sftp, smb, etc.)
  ];

  # Servicios clave para funcionalidad (papelera, montaje, redes)
  services.gvfs.enable = true;

}