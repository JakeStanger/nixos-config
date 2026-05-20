{ pkgs, ... }:
let 
  cacheHost = "penelope-12";
  cachePort = 4000;
  cacheUser = "nix-cache";
in 
 {
  nix = {
    settings.substituters = [ "http://${cacheHost}:${toString cachePort}" ];
    settings.trusted-public-keys = [
      "penelope-cache:PBOpC2twVFeqCFxI8pHkSAAMRiSx8qXr+3TmuZwgx7M=" # penelope-12:/etc/nix/cache-pub-key.pem
    ];

    settings.post-build-hook = toString
      (pkgs.writeShellScript "push-to-cache" ''
        set -euf
        nix copy --to ssh-ng://${cacheUser}@${cacheHost} $OUT_PATHS
      '');

    distributedBuilds = true;
    buildMachines = [{
      hostName = cacheHost;
      maxJobs = 4;
      system = pkgs.stdenv.hostPlatform.system;
      supportedFeatures = [ "nixos-test" "big-parallel" "kvm" ];
      sshUser = cacheUser;
      sshKey = "/etc/nix/build-machine-key";
      protocol = "ssh-ng";
    }];

    # extraOptions = ''
    #   builders-use-substitutes = true
    # '';
  };

  programs.ssh.extraConfig = ''
    Host ${cacheHost}
      User ${cacheUser}
      IdentityFile /etc/nix/build-machine-key
      StrictHostKeyChecking no
  '';
}
