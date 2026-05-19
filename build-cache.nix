{ pkgs, ... }: {
  # TODO: This has lots of hard-coded values and I don't very much like that
  nix = {
    settings.substituters = [ "http://penelope-12:4000" ];
    settings.trusted-public-keys = [
      "penelope-cache:PBOpC2twVFeqCFxI8pHkSAAMRiSx8qXr+3TmuZwgx7M=" # penelope-12:/etc/nix/cache-pub-key.pem
    ];

    settings.post-build-hook = toString
      (pkgs.writeShellScript "push-to-cache" ''
        set -euf
        nix copy --to http://penelope-12:4000?compression=zstd $OUT_PATHS
      '');

    distributedBuilds = true;
    buildMachines = [{
      hostName = "penelope-12";
      maxJobs = 4;
      system = pkgs.stdenv.hostPlatform.system;
      supportedFeatures = [ "nixos-test" "big-parallel" "kvm" ];
      sshUser = "nix-cache";
      sshKey = "/etc/nix/build-machine-key";
      protocol = "ssh-ng";
    }];

    # extraOptions = ''
    #   builders-use-substitutes = true
    # '';
  };
}
