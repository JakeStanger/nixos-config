{ hostInfo, ... }: {
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";

  nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
  nix.gc.automatic = false;
  nix.optimise.automatic = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.flake = "/etc/nixos#${hostInfo.name}";
  system.autoUpgrade.upgrade = false; # avoid updating lockfile

  nixpkgs.config.allowUnfree = true;

  users.users.jake = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ./secrets/${hostInfo.num}.yaml;
  };

  system.stateVersion = "25.11"; # INIT VERSION - DO NOT TOUCH!
}
