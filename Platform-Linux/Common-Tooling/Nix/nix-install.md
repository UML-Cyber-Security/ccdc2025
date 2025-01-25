# Nix Environment Setup

## Installing nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
  sh -s -- install
```

## Searching for packages

Most packages you might need you can find at <https://search.nixos.org/packages>.

The idea is you `devenv shell` and have a nice set of packages to work with that's some what isolated from the system

## Nix information

Any trouble or guidance regarding nix look at the wiki at <https://nixos.wiki/>

## Installing devenv and direnv

To install them to the system use:

```bash
nix profile install nixpkgs#direnv
nix profile install nixpkgs#devenv
```

## Setting up direnv

To use automatic enabling just run `direnv allow`

## Setting up devenv

Run the init in the directory

```bash
devenv init
```

Modify or replace the `devenv.nix` with the packages you want

```bash
devenv shell
```

- <https://devenv.sh/> - List all options to use, most important part is in the following part

```nix
packages = [pkgs.<package_you_want>];
```

If you want to add more just add another like this:

```nix
packages = [pkgs.<package_you_want> pkgs.<another_package_you_want>];
```
