#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="${NIXHOME_REPO:-$(cd "$HERE/.." && pwd)}"
export CARGO_TARGET_DIR="${CARGO_TARGET_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/nix-home-installer/target}"

if [ -z "${NIXHOME_BACKEND:-}" ]; then
  if command -v nix-home-installer >/dev/null 2>&1; then
    NIXHOME_BACKEND="$(command -v nix-home-installer)"
  else
    NIXHOME_BACKEND="$CARGO_TARGET_DIR/release/nix-home-installer"
    if [ ! -x "$NIXHOME_BACKEND" ]; then
      echo "Compilando el backend (una sola vez)…" >&2
      command -v notify-send >/dev/null 2>&1 && notify-send -a "Nix Home" "Instalador" "Compilando el backend (solo la primera vez)…" || true
      if command -v cargo >/dev/null 2>&1; then
        (cd "$HERE" && cargo build --release)
      else
        (cd "$HERE" && nix-shell -p cargo rustc gcc --run "cargo build --release")
      fi
    fi
  fi
fi

chmod +x "$HERE/ui/askpass.sh" 2>/dev/null || true

export NIXHOME_REPO="$REPO"
export NIXHOME_BACKEND
export QT_QUICK_CONTROLS_STYLE=Basic

if ! command -v nix-search >/dev/null 2>&1; then
  echo "Aviso: nix-search no está en PATH. Prueba: nix shell nixpkgs#nix-search-cli -c $0" >&2
fi

exec quickshell -p "$HERE/ui" "$@"
