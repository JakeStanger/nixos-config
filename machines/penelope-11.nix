{ hostInfo, lib, ... }:
{
  virtualisation.libvirt = {
    enable = true;

    connections."qemu:///system" = {
      networks = [
        {
          definition = ../configs/${hostInfo.name}/libvirtd/network.xml;
        }
      ];

      pools = [
        {
          definition = ../configs/${hostInfo.name}/libvirtd/image-pool.xml;
        }
      ];

      domains = [
        {
          definition = ../configs/${hostInfo.name}/libvirtd/vm-01.xml;
        }
      ];
    };
  };

  networking = {
    bridges.br0.interfaces = ["enp1s0f0"];

    interfaces.br0.ipv4.addresses = [{
      address = hostInfo.ipA;
      prefixLength = 24;
    }];

    interfaces.enp1s0f0 = {
      useDHCP = false;
      ipv4.addresses = lib.mkForce [];
    };
  };

  boot.kernelModules = [ "kvm-intel" ];

  users.users.jake.extraGroups = [ "libvirtd" ];

  environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";
}