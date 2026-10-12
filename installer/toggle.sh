#!/usr/bin/env bash
# Abre el instalador; si ya está abierto, lo cierra y apaga el proceso.
# Pensado para un atajo de teclado. Uso:
#   toggle.sh           abrir / cerrar (no cierra si hay un comando en ejecución)
#   toggle.sh --force   cerrar aunque haya un comando en ejecución
set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UI="$HERE/ui"

QS="$(command -v quickshell || command -v qs || true)"
[ -z "$QS" ] && { echo "toggle.sh: no encuentro quickshell en PATH" >&2; exit 1; }

notify() { command -v notify-send >/dev/null 2>&1 && notify-send -a "Nix Home" "$@" || true; }

# La sintaxis del selector de instancia ha cambiado entre versiones: probamos ambas.
ipc() {
  "$QS" -p "$UI" ipc call installer "$1" 2>/dev/null \
    || "$QS" ipc -p "$UI" call installer "$1" 2>/dev/null
}

FN="close"
[ "${1:-}" = "--force" ] && FN="quit"

if out="$(ipc "$FN")"; then
  case "$out" in
    *busy*) notify "Instalador" "Hay un comando en ejecución. Detenlo o usa: toggle.sh --force" ;;
  esac
  exit 0
fi

# Sin respuesta IPC. Si el proceso existe pero está colgado y piden --force, lo matamos.
if [ "$FN" = "quit" ] && pgrep -f -- "-p $UI" >/dev/null 2>&1; then
  pkill -f -- "-p $UI"
  exit 0
fi

# No está abierto: lanzar.
nohup setsid "$HERE/run.sh" >/dev/null 2>&1 &
exit 0
