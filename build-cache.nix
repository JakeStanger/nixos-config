{ pkgs, config, ... }:
let 
  cacheHost = "penelope-12";
  cachePort = 4000;
  cacheUser = "nix-cache";
in 
 {
  nix = {
    settings.substituters = [ "http://${cacheHost}:${toString cachePort}" ];
    settings.post-build-hook = toString
      (pkgs.writeShellScript "push-to-cache" ''
        set -euf

        exec >> /tmp/push-to-cache.log 2>&1
        echo "=== $(date) ==="
        echo "OUT_PATHS: $OUT_PATHS"
        echo "USER: $(id)"
        echo "PATH: $PATH"

        nix store sign --key-file ${config.sops.secrets.cache-priv-key.path} $OUT_PATHS
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

  sops.secrets.cache-priv-key.sopsFile = ./secrets/all.yaml;
}
