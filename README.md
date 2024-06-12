# Nixos Configuration

Nixos Configuration Repository

## Directories

### `hardware-configuration`

Contains the hardware configuration for each machine.

### `profiles`

Control plane for each machine. Each profile contains the configuration and features to be enabled for each machine.

### `home`

Contains the configuration/implementation at user level.
As much as possible, configuration should be done in here to reduce surface of attack in the system, unless requiring system-wide access like `dbus` or `kernel modules`, or `root` needs access to the programs.

### `options`

Contains the options definition to toggle features in the system. Used by [profiles](#profiles) to enable or disable features.

Options are meant to be shared between `system` and `home`. Hence, why the definitions are put in their own folder.

### `secrets`

Contains the secrets for the system. Uses [sops-nix] to encrypt the secrets.

### `system`

Contains system-wide configuration and implementation. Unless requiring system access, it's discouraged to put extended configurations here.
Only parts that require system access allowed to be here.

## Installation

### Fresh Installation

On new machine, copy this repo, copy the `hardware-configuration.nix` from `/etc/nixos/hardware-configuration.nix` to `./hardware-configuration/<hostname>.nix`.

If creating new profile and hostname, create a new `<profile>.nix` in `./profiles` and
create a new `nixosConfiguration.<hostname>` option in [`flake.nix`](./flake.nix) and
re-target the `profile-path` and `hardware-configuration` variable (`specialArgs`) to the new files.

Mount the root drive to `/mnt`, then run the following command:

```sh
nixos-install --flake /path/to/repository#<hostname>
```

### Reinstall

If fresh from installation disk, Mount the target disk to `/mnt` and run the following command (Only on reinstalls):

```sh
nixos-install --flake https://github.com/tigorlazuardi/nixos#<hostname>

# There are 2 hostnames available in this repo: 'castle' or 'fort'
```

## From Existing Installation

Same steps as [Fresh Installation](#fresh-installation), but no need to mount the root drive.

Then run the following command:

```sh
sudo nixos-rebuild switch --flake /path/to/repository#<hostname>
```

[sops-nix]: https://github.com/Mic92/sops-nix
