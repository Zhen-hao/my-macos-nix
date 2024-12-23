# macOS Nix Config

With this flake repo, you can get NixOS-like experience on macOS.

### Preparation

#### Nix
Use the [nix-installer](https://github.com/DeterminateSystems/nix-installer) is the most robust way to install Nix on macOS.

#### nix-darwin

[nix-darwin](https://github.com/LnL7/nix-darwin) needs to be installed first. 
It is important to add the `nix.settings.trusted-users` config to the nix-darwin config file before running this flake.

Note that nix-darwin will override the Nix version installed in the previous step. As of 22-07-2024, nix-darwin can not bootstrap without Nix installed first.

### Usage

Once the preparation steps are done, you can get NixOS experience (managing software and services declaratively with Nix) on your macOS with this flake repo.

#### Update
`nix run .#update`

#### Activate
`nix run .#activate`

### Source

[Flake Templates](https://community.flake.parts/nixos-flake/templates)

The source code of the template is [nixos-flake](https://github.com/srid/nixos-flake?tab=readme-ov-file)

Also see [nixos-unified](https://github.com/srid/nixos-unified)