{ hostInfo, lib, pkgs, ... }: 
let 
  vm-script = pkgs.writeShellScriptBin "vm"
      (builtins.readFile ../configs/penelope-11/vm.sh);
in
{
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
  };

  security.sudo.extraRules = [{
    users = [ "ali " ];
    runAs = "root";
    commands = [{
      command = "${vm-script}/bin/vm";
      options = [ "NOPASSWD" ];
    }
    {
      command = "/run/current-system/sw/bin/vm";
      options = [ "NOPASSWD" ];
    }];
  }];

  environment.systemPackages = [ vm-script ];

  environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";
}
