{ hostInfo, lib, pkgs, ... }: {
  virtualisation.libvirt = {
    enable = true;

    connections."qemu:///system" = {
      networks =
        [{ definition = ../configs/${hostInfo.name}/libvirtd/network.xml; }];

      pools =
        [{ definition = ../configs/${hostInfo.name}/libvirtd/image-pool.xml; }];

      domains =
        [{ definition = ../configs/${hostInfo.name}/libvirtd/vm-01.xml; }];
    };
  };

  networking = {
    bridges.br0.interfaces = [ "enp1s0f0" ];

    interfaces.br0.ipv4.addresses = [{
      address = hostInfo.ipA;
      prefixLength = 24;
    }];

    interfaces.enp1s0f0 = {
      useDHCP = false;
      ipv4.addresses = lib.mkForce [ ];
    };
  };

  users.users = {
    jake.extraGroups = [ "libvirtd" ];

    ali.isNormalUser = true;
    ali.extraGroups = [ "vm-user" ];

    vm-user = {
      isSystemUser = true;
      group = "vm-user";
      extraGroups = [ "libvirtd" ];
    };
  };

  users.groups.vm-user = {};

  security.sudo.extraRules = [{
    users = [ "ali " ];
    runAs = "vm-user";
    commands = [{
      command = "/opt/vm";
      options = [ "NOPASSWD" ];
    }];
  }];

  system.activationScripts.vmScript = ''
    install -Dm755 ${
      pkgs.writeShellScript "vm.sh"
      (builtins.readFile ../configs/penelope-11/vm.sh)
    } /opt/vm
  '';

  environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";
}
