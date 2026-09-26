{ config, pkgs, ... }:

{
  # ─────────────────────────────────────────────
  # Nixpkgs overlays
  # ─────────────────────────────────────────────

  nixpkgs.overlays = [
    (final: prev: {
      suwayomi-server = prev.suwayomi-server.overrideAttrs (oldAttrs: {
        version = "2.3.2243";

        src = final.fetchurl {
          url = "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v2.3.2243/Suwayomi-Server-v2.3.2243.jar";
          hash = "sha256-ghFBsy4XDUoC08vf7Vd+2PB70iOD/19BMuu1rkDpjdU=";
        };
      });
    })
  ];

  # ─────────────────────────────────────────────
  # Directorios de Tachidesk
  # ─────────────────────────────────────────────

  systemd.user.tmpfiles.rules = [
    "d %h/.local/share/Tachidesk 0755 - - -"
    "d %h/.local/share/Tachidesk/extensions 0755 - - -"
    "d %h/.local/share/Tachidesk/backups 0755 - - -"
    "d %h/Manga 0755 - - -"
    "d %h/Manga/Downloads 0755 - - -"
  ];

  # ─────────────────────────────────────────────
  # Suwayomi Server
  # ─────────────────────────────────────────────

  environment.systemPackages = with pkgs; [
    suwayomi-server

    (writeShellScriptBin "tachidesk" ''
      case "$1" in
        start)
          systemctl --user start tachidesk.service
          ;;

        stop)
          systemctl --user stop tachidesk.service
          ;;

        restart)
          systemctl --user restart tachidesk.service
          ;;

        status)
          systemctl --user status tachidesk.service --no-pager
          ;;

        enable)
          systemctl --user enable tachidesk.service
          ;;

        disable)
          systemctl --user disable tachidesk.service
          ;;

        *)
          echo "Usage: tachidesk {start|stop|restart|status|enable|disable}"
          exit 1
          ;;
      esac
    '')
  ];

  # ─────────────────────────────────────────────
  # Tachidesk user service
  # ─────────────────────────────────────────────

  systemd.user.services.tachidesk = {
    description = "Tachidesk Server";

    after = [
      "network-online.target"
    ];

    wants = [
      "network-online.target"
    ];

    # Se controla manualmente con el comando "tachidesk".

    serviceConfig = {
      ExecStart = "${pkgs.suwayomi-server}/bin/tachidesk-server";

      WorkingDirectory = "%h/.local/share/Tachidesk";

      # HOME explícito: sin esto, la JVM no resuelve bien "user.home"
      # dentro de la unidad de usuario y el servidor cae en /tmp/Tachidesk
      # en vez de usar ~/.local/share/Tachidesk.
      Environment = [
        "HOME=%h"
      ];

      Restart = "on-failure";
      RestartSec = 5;

      # Apagado limpio: le da tiempo a la JVM a cerrar bien
      # antes de que systemd mate el proceso.
      TimeoutStopSec = 15;
      KillSignal = "SIGTERM";
    };
  };
}