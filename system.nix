{ hostInfo, config, ... }: 
{
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
  };

  boot.supportedFilesystems = [ "nfs" ];

  fileSystems."/storage" = {
    device = "chloe:/storage";
    fsType = "nfs";
  };

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";

  nix = {
    settings.experimental-features =
      [ "nix-command" "flakes" "pipe-operators" ];
    gc.automatic = false;
    optimise.automatic = true;

    settings.substituters = [ "https://cache.garnix.io" ];

    settings.trusted-public-keys =
      [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];

      # TODO: `builders-use-subtituters` should be in build-cache.nix
      # but setting extraOptions here overrides that.
      # we need a way to build up modules & merge it.
      extraOptions = ''
        builders-use-substitutes = true
        !include ${config.sops.templates."github-token.conf".path}
      '';
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.flake = "github:jakestanger/nixos-config#${hostInfo.name}";
  system.autoUpgrade.upgrade = false; # avoid updating lockfile

  nixpkgs.config.allowUnfree = true;

  users.users.jake = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ./secrets/${hostInfo.name}.yaml;

    secrets.github-token.sopsFile = ./secrets/all.yaml;
    templates."github-token.conf".content = ''
      access-tokens = github.com=${config.sops.placeholder.github-token}
    '';
  };

  system.stateVersion = "25.11"; # INIT VERSION - DO NOT TOUCH!
}
