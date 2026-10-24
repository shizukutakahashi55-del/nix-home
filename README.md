# ❄️ NixOS Configuration

A modular NixOS configuration using **Flakes** and **Home Manager**,
with Hyprland, niri, MangoWM, QuickShell, NVIDIA support, gaming tools,
and development packages.

This repository is tailored to my own PC. **Do not apply it without
reviewing the machine-specific settings first.** My desktop dotfiles are
maintained separately in
[dotfiles-nix](https://github.com/shizukutakahashi55-del/dotfiles-nix).

## What's included

-   **Window managers:** Hyprland, niri, and MangoWM.
-   **Desktop:** QuickShell, lock/idle tools, wallpapers, screenshots,
    clipboard utilities, and theming.
-   **System:** PipeWire, Bluetooth, NetworkManager, Flatpak, polkit,
    and QEMU.
-   **Graphics:** NVIDIA drivers and OBS/CUDA configuration. An AMD
    alternative may be available in the modules.
-   **Gaming:** Steam with Millennium, Lutris, Wine/Proton tools,
    MangoHud, and Prism Launcher.
-   **Apps:** Browsers, communication, development, terminal, file
    management, and multimedia tools configured with Home Manager.
-   **Installer:** A QuickShell GUI for editing supported Nix files,
    reviewing changes, and building/testing/applying the configuration.

## Before installing

Requirements:

-   An existing **NixOS 26.05** installation.
-   `x86_64-linux` and UEFI.
-   Git and Flakes enabled.

This configuration includes hardware- and user-specific values. Review
at least:

-   `hardware-configuration.nix`
-   `modules/users.nix` and `home/default.nix`
-   `modules/networking.nix`
-   `flake.nix` and `configuration.nix`
-   GPU and filesystem-related modules

## Installation

### 1. Clone the repository

``` bash
git clone https://github.com/shizukutakahashi55-del/nix-home.git ~/nix-home
cd ~/nix-home
```

### 2. Generate your hardware configuration

Do not reuse the repository's `hardware-configuration.nix` on another
machine. Replace it with the one for your current installation:

``` bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

Check the generated file before continuing.

### 3. Change the username

Find your current username:

``` bash
whoami
```

Replace the example username `oozenix` with your own wherever it is
hard-coded (mainly `modules/users.nix` and `home/default.nix`). Find all
occurrences from the repository root with:

``` bash
grep -RIn --exclude-dir=.git 'oozenix' .
```

Do not blindly replace every match: check whether each occurrence is a
username, a path (`/home/oozenix`), or an unrelated string.

### 4. Adapt the rest of the configuration

Update the hostname, timezone, locale, GPU, and any filesystem-specific
settings to match your machine.

The flake defines the host as `nixos`, so the commands in this README use
`.#nixos`. If you rename the host in `flake.nix`, update the commands
accordingly.

For an AMD system, review the GPU imports in `configuration.nix` and the
OBS module before building. Do not enable both GPU configurations.

### 5. Add new files to Git

Flakes only see files tracked by Git, so any file you create or rename
must be staged before rebuilding. Check what changed first:

``` bash
git status --short
```

Then stage what you intend to include:

``` bash
git add hardware-configuration.nix configuration.nix flake.nix modules home
```

### 6. Build and apply

Check that the configuration builds:

``` bash
sudo nixos-rebuild dry-build --flake .#nixos
```

Then activate it:

``` bash
sudo nixos-rebuild switch --flake .#nixos
```

Reboot if required. Home Manager is integrated into the NixOS
configuration, so you do not need to run `home-manager switch`
separately.

## Updating

To get the latest changes from this repository without losing your own
edits (username, hardware configuration, etc.):

``` bash
cd ~/nix-home
git stash            # save your local changes
git pull             # download the latest version
git stash pop        # re-apply your changes
```

If `git stash pop` reports conflicts, open the marked files, keep the
values that apply to your machine, and then run `git add` on them.

Then review and apply:

``` bash
git diff HEAD@{1} -- flake.lock     # optional: see which inputs changed
sudo nixos-rebuild dry-build --flake .#nixos
sudo nixos-rebuild switch --flake .#nixos
```

Notes:

-   If the update added new files that mention `oozenix`, repeat the
    `grep` from [step 3](#3-change-the-username).
-   If you downloaded the repository as a ZIP instead of cloning it,
    `git pull` is not available. Download the new ZIP, copy your edited
    files (`hardware-configuration.nix`, `modules/users.nix`,
    `home/default.nix`, etc.) over it, or switch to `git clone` to make
    future updates easier.
-   If something breaks, go back to the previous generation with
    `sudo nixos-rebuild switch --rollback`.

## Common commands

Run these from the repository directory.

| Command | Purpose |
|---|---|
| `nix flake update` | Update flake inputs and rewrite `flake.lock`. Only run it if you intend to update dependencies, and review the changes first. |
| `sudo nixos-rebuild dry-build --flake .#nixos` | Check whether the configuration builds without activating it. |
| `sudo nixos-rebuild build --flake .#nixos` | Build the system configuration without activating it. |
| `sudo nixos-rebuild test --flake .#nixos` | Activate the configuration temporarily; it will not become the boot default. |
| `sudo nixos-rebuild switch --flake .#nixos` | Build and activate the configuration and make it the current system generation. |
| `sudo nixos-rebuild boot --flake .#nixos` | Build and set it as the next boot default without activating it now. |
| `sudo nixos-rebuild switch --rollback` | Switch to the previous system generation. |
| `git status --short` | Show modified and untracked files. |
| `git diff` | Review unstaged changes. |

**Tip:** Changes to the compositor, display manager, or login screen can
end your graphical session. Apply them from a TTY, or use
`sudo nixos-rebuild boot --flake .#nixos` and reboot. If the login screen
fails, switch to another TTY (Ctrl+Alt+F2) and run
`sudo nixos-rebuild switch --rollback`.

## Graphical installer

The `installer/` directory contains a QuickShell GUI for managing
supported `.nix` files in this repository. It includes package
search/editing, a change review, a Nix file editor, and controls to
validate, test, and apply changes. Review each change before applying it.

If QuickShell and `nix-search-cli` are not already available, launch it
with:

``` bash
nix shell -p quickshell nix-search-cli -c ./installer/run.sh
```

Otherwise, run:

``` bash
./installer/run.sh
```

To toggle the installer from a keybinding:

``` bash
./installer/toggle.sh
```

To force it to close even if a command is running:

``` bash
./installer/toggle.sh --force
```

The Rust backend is built outside the repository by default, under
`~/.cache/nix-home-installer/target`. You can override the build
location with `CARGO_TARGET_DIR`.

## OozeLogin (login screen)

`modules/greetd.nix` enables OozeLogin, a QuickShell greeter for greetd
with its own settings window. It replaces tuigreet. Details in
`modules/oozelogin/README.md`.

| Command | Purpose |
|---|---|
| `oozelogin-settings` | Settings window (appearance, panels, access, weather, OozeShell) |
| `oozelogin-preview` | Run the greeter in a window to test it (test password: `ooze`) |
| `oozelogin-sync` | Copy OozeShell colors, wallpaper and avatar to the greeter |

`sync.enable = true` runs the sync automatically whenever the matugen
palette, the awww wallpaper or the OozeShell profile change. Your user
must be in the `users` group to edit the greeter settings. Test with
`oozelogin-preview` before applying.

## Repository layout

```text
.
├── flake.nix
├── flake.lock
├── configuration.nix
├── hardware-configuration.nix
├── modules/       # System modules, drivers, services, and OozeLogin
├── home/          # Home Manager configuration and user applications
└── installer/     # QuickShell interface and Rust backend
```

## Important notes

-   **System version:** Keep `system.stateVersion` and Home Manager's
    `home.stateVersion` consistent with the version used when the system
    was first installed. Do not change them just to upgrade NixOS.
-   **NVIDIA environment:** `modules/nvidia.nix` sets graphics-related
    environment variables. If your compositor config sets the same
    variables, keep the values consistent.
-   **Polkit:** Review `modules/polkit.nix`; it defines which privileged
    power actions can be performed without a password.
-   **Maintenance:** Review `modules/maintenance.nix` and make sure its
    Btrfs maintenance settings match your filesystem.
-   **flake.lock:** Keep it committed when the configuration is in a
    known-good state, since `nix flake update` can introduce upstream
    changes.