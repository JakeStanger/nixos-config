{
  description = "penelope";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:Nixos/nixpkgs/nixos-unstable";

    # until <https://github.com/NixOS/nixpkgs/pull/495646> merges
    nixpkgs-pcp.url = "github:randomizedcoder/nixpkgs/pcp";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-virt.url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
    nix-virt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ self, nixpkgs, nixpkgs-unstable, nixpkgs-pcp, sops-nix, nix-virt, ... }:
    let
      system = "x86_64-linux";

      pkgs = inputs.nixpkgs.legacyPackages.${system};
      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};

      toPadded = n: pkgs.lib.fixedWidthString 2 "0" (toString n);
      toIp = n: "192.168.1.1${toPadded n}";
      toHost = n: "penelope-${toPadded n}";

      hostMap = builtins.genList (x: x + 1) 12
        |> map (n: {
          num = toPadded n;
          name = toHost n;
          ipA = toIp n;
          ipB = toIp (n + 12);
        })
        |> builtins.groupBy (host: host.name)
        |> builtins.mapAttrs (name: value: builtins.head value);
    in {
      nixosConfigurations = hostMap |> builtins.mapAttrs (name: hostInfo: nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          "${nixpkgs-pcp}/nixos/modules/services/monitoring/pcp.nix"
          ({ ... }: {
            nixpkgs.overlays = [
              (final: prev: {
                pcp = (import nixpkgs-pcp { inherit system; }).pcp;

                # cockpit-bridge does not talk to pcp by default
                # so we rewrite the script here with patched env vars
                cockpit = prev.cockpit.overrideAttrs (old: {
                  postFixup = (old.postFixup or "") + ''
                      cp ${
                        pkgs.writeShellScript "cockpit-bridge" ''
                          export LD_LIBRARY_PATH="${final.pcp}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"  export PCP_LOG_DIR="/var/log/pcp"
                            export PYTHONPATH="${final.pcp}/lib/python3.13/site-packages:COCKPIT_OUT/lib/python3.13/site-packages''${PYTHONPATH:+:$PYTHONPATH}"
                            exec -a "$0" "COCKPIT_OUT/bin/.cockpit-bridge-wrapped" "$@"
                        ''
                      } $out/bin/cockpit-bridge
                    sed -i "s|COCKPIT_OUT|$out|g" $out/bin/cockpit-bridge
                    chmod +x $out/bin/cockpit-bridge
                  '';
                });
              })
            ];
          })

          
          sops-nix.nixosModules.sops
          nix-virt.nixosModules.default

          ./configuration.nix
        ];

        specialArgs = { inherit hostInfo pkgs-unstable; };
      });
    };
}
