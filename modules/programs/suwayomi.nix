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
  # Suwayomi Server
  # ─────────────────────────────────────────────

  environment.systemPackages = with pkgs; [
    suwayomi-server

    # Tachidesk command
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
          systemctl --user status tachidesk.service
          ;;

        *)
          echo "Usage: tachidesk {start|stop|restart|status}"
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

    serviceConfig = {
      ExecStart = "${pkgs.suwayomi-server}/bin/tachidesk-server";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}