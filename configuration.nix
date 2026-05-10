# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ lib, hostInfo, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./system.nix
    ./networking.nix
    ./monitoring.nix
    ./containers.nix
    ./shell.nix
    ./backup.nix
  ]  ++ lib.optional (builtins.pathExists ./machines/${hostInfo.name}.nix) ./machines/${hostInfo.name}.nix;
}

