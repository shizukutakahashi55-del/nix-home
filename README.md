# ❄️ NixOS Configuration

Modular NixOS setup using **Flakes** and **Home Manager**: **Hyprland** + **QuickShell** on Wayland, an **NVIDIA** GPU, plus gaming and development tools.

This is the config of my own machine, so read [Before you use it](#before-you-use-it) first. My Hyprland/QuickShell dotfiles live in a separate repo: [dotfiles-nix](https://github.com/shizukutakahashi55-del/dotfiles-nix).

## What's inside

* **Session:** greetd + tuigreet → Hyprland (UWSM, XWayland), taken from the upstream Hyprland flake.
* **Desktop tools:** QuickShell, Hyprlock/Hypridle, Hyprpaper, awww + Waypaper + Matugen, wlogout, grim/slurp, Wayland clipboard.
* **GPU:** NVIDIA proprietary driver with VA-API/VDPAU, OBS with CUDA. An AMD module is included (see the table below).
* **System:** PipeWire, Bluetooth, NetworkManager, Flatpak (Flathub), UPower, power-profiles-daemon, polkit.
* **Gaming:** Steam (Millennium), Lutris, Wine, Proton tools, MangoHud, Prism Launcher.
* **User apps (Home Manager):** browsers, Discord/Telegram/Spotify/Sonora, dev tools, terminals + Zsh, Dolphin, mpv/VLC, dark GTK theme, Japanese input (fcitx5 + Mozc).
* **Extras:** Suwayomi manga server, controlled with the `tachidesk` command (`start|stop|restart|status|enable|disable`).
* **Maintenance:** weekly garbage collection (deletes generations older than 5 days), store optimisation, at most 10 boot entries, Btrfs scrub + fstrim.

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
nix flake update                            # update the inputs
sudo nixos-rebuild switch --flake .#nixos   # apply
sudo nixos-rebuild test --flake .#nixos     # try it; reverts on reboot
sudo nixos-rebuild switch --rollback        # go back to the previous generation
```

New plain apps go in `home/programs/`. Only things that need system integration go in `modules/`: drivers, setuid wrappers, system services, or overlays (OBS, Steam, Suwayomi).

## Repository structure

```text
├── flake.nix                    # inputs and the `nixos` host
├── configuration.nix            # imports every module + Home Manager setup
├── hardware-configuration.nix   # machine-specific, regenerate it
├── modules/
│   ├── boot.nix                 # systemd-boot, stable kernel
│   ├── desktop.nix              # greetd + tuigreet, AppImage, printing, fonts
│   ├── hyprland.nix             # Hyprland, QuickShell wrapper and desktop packages
│   ├── nvidia.nix               # NVIDIA driver, VA-API/VDPAU, env variables
│   ├── amdgpu.nix               # AMD alternative to nvidia.nix
│   ├── audio.nix                # PipeWire
│   ├── networking.nix           # hostname, NetworkManager, Bluetooth, timezone, keyboard
│   ├── users.nix                # system user
│   ├── polkit.nix               # hyprpolkitagent + passwordless power/reboot/profile rules
│   ├── maintenance.nix          # GC, boot entry limit, Btrfs scrub, fstrim
│   ├── programs/                # kde.nix (Plasma, currently disabled), obs.nix, steam.nix, suwayomi.nix
│   └── services/                # flatpak.nix, systemservices.nix (UPower, power-profiles-daemon)
└── home/
    ├── default.nix              # username, home dir, stateVersion, imports
    └── programs/                # browsers, communication, development, gaming, gtk,
                                 # japanese, media, system, terminal
```

## Before you use it

| What | Where |
| --- | --- |
| Username `oozenix` | `modules/users.nix`, `home/default.nix` (username + home dir), `configuration.nix` (`home-manager.users.oozenix`) |
| Hostname `nixos` | `modules/networking.nix` and `nixosConfigurations.nixos` in `flake.nix`. Change both and use the new name in `--flake .#<host>` |
| NVIDIA GPU | With AMD, swap `nvidia.nix` for `amdgpu.nix` in `configuration.nix` and remove the `obs.nix` import (it is CUDA-only) |
| Timezone / locale / keyboard | `modules/networking.nix` (`America/Phoenix`, `en_US.UTF-8`, `us`) |
| Btrfs maintenance | `modules/maintenance.nix`. Remove the scrub block if `/` isn't Btrfs |
| `stateVersion` (`26.05`) | `configuration.nix`, `home/default.nix`. Keep it equal to the release you first installed and don't change it later |
| External flakes | Millennium (Steam), Sonora, Hyprland. Check they are still maintained |

Review the modules before applying this on a machine you care about.

## Notes

* **NVIDIA variables:** `modules/nvidia.nix` sets `LIBVA_DRIVER_NAME`, `__GLX_VENDOR_LIBRARY_NAME` and `NVD_BACKEND` system-wide. If your Hyprland config also sets them with `env = …`, keep the values identical in both places, or you'll get inconsistent behaviour that is hard to trace.
* **Polkit:** users in `wheel` can reboot, power off, suspend, hibernate and change power profiles without a password. Edit `modules/polkit.nix` if you don't want that.
* **Waybar / Rofi / SwayNC:** commented out in `modules/hyprland.nix`. Uncomment them if you don't use QuickShell.
* **Hyprland tracks upstream:** `nix flake update` can bring in breaking changes. `flake.lock` keeps the working version, so commit it after a good update.