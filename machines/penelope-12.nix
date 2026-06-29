{ pkgs, ... }:
let
  port = 4000;
  cpu-cores = 4;
in {
  nix.settings.trusted-users = [ "nix-cache" ];

  users.users.nix-cache = {
    isSystemUser = true;
    useDefaultShell = true;

    group = "nix-cache";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0QB/d1MjWl0cNX+cujQZkxOk18VrMFUMbOqM8mvK6Y nix-build" # penelope-01
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKosmldI1zdM8cxgVikbB8js27G/xMaHU2LR9UJI3Wxt nix-build" # penelope-02
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJcUWGB119aJyxLwMf7lyHmAYJwPHENaE7AtbkdchdEb nix-build" # penelope-03
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAeFRUJ4OBYtX/rz7g/qVIRVtPjtDnIx9pDAxoSaIkwv nix-build" # penelope-04
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzf3nUxurDbTbkGvjSxwhfv/WYwalv1ql4rZcnZpDsS nix-build" # penelope-05
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImywOC6P3R/hj/Z6EujUoMAoiR7lztw39Li/XA0a7hO nix-build" # penelope-06
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJUBtp/aAs66aQO1wOv6sTjdWYYg3y4Cxd76edGWJJYI nix-build" # penelope-07
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5Qd9iyEXcbScmv2VqexwUrP3pORz5afV2jBe+2yisi nix-build" # penelope-08
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHn+6VreHIq0nh9Ddn7aKEjS/tSTgsWOZByN7dRmEQy4 nix-build" # penelope-09
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILL9YtO2cUT2HwnO+jb6kzwNonw9rBWS7YffSBYgCL2r nix-build" # penelope-10
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAcs2/WpFOR5njpcLY01egwnCRlWI4gWVY95Z8HzsG/ nix-build" # penelope-11
    ];
  };

  users.groups.nix-cache = { };

  services.harmonia = {
    enable = true;
    package = pkgs.harmonia;

    signKeyPaths = [ "/etc/nix/cache-priv-key.pem" ];
    settings = {
      bind = "0.0.0.0:${toString port}";
      workers = cpu-cores;
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
