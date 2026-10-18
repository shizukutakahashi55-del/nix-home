# ❄️ NixOS Configuration

Modular NixOS setup using **Flakes** and **Home Manager**: **Hyprland**, **niri** and **MangoWM** + **QuickShell** on Wayland, an **NVIDIA** GPU, plus gaming and development tools. It ships with a **graphical installer** (QuickShell) that edits, validates and applies the configuration for you.

This is the config of my own machine, so read [Before you use it](#before-you-use-it) first. My Hyprland/QuickShell dotfiles live in a separate repo: [dotfiles-nix](https://github.com/shizukutakahashi55-del/dotfiles-nix).

## What's inside

* **Sessions:** greetd + tuigreet → Hyprland (UWSM, XWayland, from the upstream flake), niri (with xwayland-satellite) or MangoWM.
* **Desktop tools:** QuickShell, Hyprlock/Hypridle, Hyprpaper, awww + Waypaper + Matugen, wlogout, grim/slurp, Wayland clipboard.
* **GPU:** NVIDIA proprietary driver with VA-API/VDPAU, OBS with CUDA. An AMD module is included (see the table below).
* **System:** PipeWire, Bluetooth, NetworkManager, Flatpak (Flathub), UPower, power-profiles-daemon, polkit, QEMU.
* **Gaming:** Steam (Millennium), Lutris, Wine, Proton tools, MangoHud, Prism Launcher.
* **User apps (Home Manager):** browsers, Discord/Telegram/Spotify/Sonora, dev tools, terminals + Zsh, Dolphin, mpv/VLC, dark GTK theme, Japanese input (fcitx5 + Mozc).
* **Extras:** Suwayomi manga server, controlled with the `tachidesk` command (`start|stop|restart|status|enable|disable`).
* **Maintenance:** weekly garbage collection (deletes generations older than 5 days), store optimisation, at most 10 boot entries, Btrfs scrub + fstrim.
* **Installer:** QuickShell app in `installer/` to search nixpkgs, add or remove packages, review diffs and run `dry-build` / `test` / `switch` with live output. See [Graphical installer](#graphical-installer).

## Installation

**Requirements:** NixOS already installed (release 26.05), UEFI boot, x86_64, and `git` (`nix-shell -p git` if you don't have it).

**1. Clone the repo**

```bash
git clone https://github.com/shizukutakahashi55-del/nix-home.git ~/nix-home
cd ~/nix-home
```

**2. Replace `hardware-configuration.nix` with your own.** The one in the repo belongs to my PC (disks, filesystems). Never reuse it.

```bash
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

**3. Adapt the personal values** (user, hostname, GPU, timezone…). See the table below.

**4. Stage the files.** Flakes ignore files that git doesn't track.

```bash
git add -A
```

**5. Apply and reboot**

```bash
sudo nixos-rebuild switch --flake .#nixos
reboot
```

Home Manager is part of this same rebuild, so there is no separate `home-manager` command. The first build can take a while.

## Day to day

```bash
nix flake update
sudo nixos-rebuild switch --flake .#nixos
sudo nixos-rebuild test --flake .#nixos
sudo nixos-rebuild switch --rollback
```

| Command | What it does |
| --- | --- |
| `nix flake update` | Updates the inputs and rewrites `flake.lock` |
| `nixos-rebuild switch` | Builds and activates the configuration |
| `nixos-rebuild test` | Activates it without making it the boot default; a reboot reverts it |
| `nixos-rebuild switch --rollback` | Goes back to the previous generation |

New plain apps go in `home/programs/`. Only things that need system integration go in `modules/`: drivers, setuid wrappers, system services, or overlays (OBS, Steam, Suwayomi).

## Graphical installer

`installer/` contains a QuickShell app that manages this repository. It needs `quickshell` and `nix-search-cli` in `PATH` (`nix shell nixpkgs#nix-search-cli`).

```bash
./installer/run.sh
./installer/toggle.sh
```

| Script | Purpose |
| --- | --- |
| `run.sh` | Builds the Rust backend the first time and opens the app |
| `toggle.sh` | Opens the app, or closes it if it is already open; meant for a keybinding |
| `toggle.sh --force` | Closes it even if a command is still running |

### Tabs

| Tab | Shortcut | What it does |
| --- | --- | --- |
| Packages | `Ctrl+1` | Searches nixpkgs (same channel as the flake), adds or removes entries in `home.packages` / `environment.systemPackages`, and tests a package build |
| Changes | `Ctrl+2` | Shows the diff since the last accepted state and can undo everything |
| Terminal | `Ctrl+3` | Runs Validate (`dry-build`) → Test → Apply (`switch`) with live output; `.nix:line` errors open the Editor on that line |
| Editor | `Ctrl+4` | Edits any `.nix` file in the repo (`Ctrl+S` saves, syntax check, external editor) |
| Settings | `Ctrl+5` | Palette, accent colour, corners, text size, font, opacity, animations, and the ready-made keybinding lines |

### Safety

* Before the first edit of each file, a copy goes to `.installer/snapshots/`, which is ignored by git. After a successful `switch` the changes are accepted and the snapshots are deleted.
* Only `.nix` files inside the repo are edited. `test` and `switch` never run without you pressing the button.
* The sudo password is asked in a dialog, lives only in memory and reaches `sudo -A` through `installer/ui/askpass.sh`.

### Keybinding

Replace the path if the repo is not in `~/nix-home`. The Settings tab shows these lines with your real path.

```lua
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.exec_cmd("~/nix-home/installer/toggle.sh"))
```

```kdl
binds {
    Mod+Shift+U repeat=false { spawn "~/nix-home/installer/toggle.sh"; }
}
```

```ini
bind=SUPER+SHIFT,U,spawn_shell,~/nix-home/installer/toggle.sh
```

The first block is Hyprland, the second niri and the third MangoWM. More details are in `installer/README.md`.

### Manual rebuild with the installer inside the repo

`nixos-rebuild --flake` copies the flake sources to `/nix/store` before evaluating, so build artifacts inside the repo can break it. For that reason `run.sh` compiles the backend outside the repository.

| Item | Value |
| --- | --- |
| Build directory | `~/.cache/nix-home-installer/target` (override with `CARGO_TARGET_DIR`) |
| Backend binary | `~/.cache/nix-home-installer/target/release/nix-home-installer` |

Rules to avoid rebuild errors from the terminal:

* Keep the repo a git repository and run `git add -A` before rebuilding; untracked files are invisible to the flake and ignored ones are not copied.
* Run the first `switch` after a `nix flake update` from a tty, not from inside the graphical session.

## Repository structure

```text
├── flake.nix                    # inputs and the `nixos` host
├── configuration.nix            # imports every module + Home Manager setup
├── hardware-configuration.nix   # machine-specific, regenerate it
├── modules/
│   ├── boot.nix                 # systemd-boot, stable kernel
│   ├── desktop.nix              # greetd + tuigreet, AppImage, nix-ld, udisks2
│   ├── hyprland.nix             # Hyprland (UWSM) and Hypr ecosystem packages
│   ├── niri.nix                 # niri + xwayland-satellite
│   ├── mango.nix                # MangoWM module from its flake
│   ├── quickshell.nix           # QuickShell wrapped with the QML import path
│   ├── nvidia.nix               # NVIDIA driver, VA-API/VDPAU, env variables
│   ├── amdgpu.nix               # AMD alternative to nvidia.nix
│   ├── audio.nix                # PipeWire
│   ├── networking.nix           # hostname, NetworkManager, Bluetooth, timezone, keyboard
│   ├── users.nix                # system user
│   ├── polkit.nix               # hyprpolkitagent + passwordless power/reboot/profile rules
│   ├── qemu.nix                 # virtualisation
│   ├── maintenance.nix          # GC, boot entry limit, Btrfs scrub, fstrim
│   ├── programs/                # kde.nix (Plasma, currently disabled), obs.nix, steam.nix, suwayomi.nix
│   └── services/                # flatpak.nix, systemservices.nix (UPower, power-profiles-daemon)
├── home/
│   ├── default.nix              # username, home dir, stateVersion, imports
│   └── programs/                # audio, browsers, communication, desktop, development, fcitx5,
│                                # files, gaming, media, system, terminal, theming, wallpaper, wayland
└── installer/
    ├── run.sh                   # builds the backend and launches the app
    ├── toggle.sh                # open/close through QuickShell IPC
    ├── Cargo.toml               # backend crate (no dependencies)
    ├── src/main.rs              # backend: status, add, remove, diff, snapshots
    ├── catalog/categories.json  # keywords that suggest the target .nix file
    └── ui/                      # QuickShell interface (QML) and askpass.sh
    
    installer inside
```

## Before you use it

| What | Where |
| --- | --- |
| Username `oozenix` | `modules/users.nix`, `home/default.nix` (username + home dir), `configuration.nix` (`home-manager.users.oozenix`) |
| Hostname `nixos` | `modules/networking.nix` and `nixosConfigurations.nixos` in `flake.nix`. Change both and use the new name in `--flake .#<host>` |
| NVIDIA GPU | With AMD, swap `nvidia.nix` for `amdgpu.nix` in `configuration.nix` and remove the `obs.nix` import (it is CUDA-only you need to install it on other file) |
| Timezone / locale / keyboard | `modules/networking.nix` (`America/Phoenix`, `en_US.UTF-8`, `us`) |
| Btrfs maintenance | `modules/maintenance.nix`. Remove the scrub block if `/` isn't Btrfs |
| `stateVersion` (`26.05`) | `configuration.nix`, `home/default.nix`. Keep it equal to the release you first installed and don't change it later |
| External flakes | Millennium (Steam), Sonora, Hyprland, MangoWM, amane, QuickShell. Check they are still maintained |
| Installer host | The app runs the rebuild against the first host found in `flake.nix` (`nixosConfigurations.<host>`) |

Review the modules before applying this on a machine you care about.

## Notes

* **NVIDIA variables:** `modules/nvidia.nix` sets `LIBVA_DRIVER_NAME`, `__GLX_VENDOR_LIBRARY_NAME` and `NVD_BACKEND` system-wide. If your Hyprland config also sets them with `env = …`, keep the values identical in both places, or you'll get inconsistent behaviour that is hard to trace.
* **Polkit:** users in `wheel` can reboot, power off, suspend, hibernate and change power profiles without a password. Edit `modules/polkit.nix` if you don't want that.
* **Hyprland tracks upstream:** `nix flake update` can bring in breaking changes. `flake.lock` keeps the working version, so commit it after a good update.
* **Switching inside the session:** a `switch` that changes the compositor or the display manager can end the graphical session. Apply those changes from a tty, or use `nixos-rebuild boot` and reboot.
* **New files:** the installer only edits existing `.nix` files. If you create a new one, run `git add` before rebuilding.