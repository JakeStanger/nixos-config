# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ lib, hostInfo, ... }:
let
  cacheHost = "penelope-12";
  isCacheServer = hostInfo.name == cacheHost;

  host-path = ./machines/${hostInfo.name}.nix;
in {
  imports = lib.optional (!isCacheServer) ./build-cache.nix ++ [
    ./hardware-configuration.nix
    ./system.nix
    ./networking.nix
    ./monitoring.nix
    ./containers.nix
    ./shell.nix
    ./backup.nix
  ] ++ lib.optional (builtins.pathExists host-path) host-path;
}

