{ hostInfo, ... }:
{
  networking = {
    hostName = hostInfo.name;

    networkmanager.enable = true;

    interfaces = {
      enp1s0f0.ipv4.addresses = [{
        address = hostInfo.ipA;
        prefixLength = 24;
      }];
      # enp1s0f1.ipv4.addresses = [{
      #   address = hostInfo.ipB;
      #   prefixLength = 24;
      # }];
    };

    defaultGateway = "192.168.1.1";

    nameservers = [ "192.168.1.3" "1.1.1.1" "8.8.8.8" "8.8.4.4" ];

    hosts = {
      "192.168.1.3" = [ "chloe" "chloe.lan" ];

      "192.168.1.100" = [ "penelope-01" "penelope-01.lan" ];
      "192.168.1.102" = [ "penelope-02" "penelope-02.lan" ];
      "192.168.1.103" = [ "penelope-03" "penelope-03.lan" ];
      "192.168.1.104" = [ "penelope-04" "penelope-04.lan" ];
      "192.168.1.105" = [ "penelope-05" "penelope-05.lan" ];
      "192.168.1.106" = [ "penelope-06" "penelope-06.lan" ];
      "192.168.1.107" = [ "penelope-07" "penelope-07.lan" ];
      "192.168.1.108" = [ "penelope-08" "penelope-08.lan" ];
      "192.168.1.109" = [ "penelope-09" "penelope-09.lan" ];
      "192.168.1.110" = [ "penelope-10" "penelope-10.lan" ];
      "192.168.1.111" = [ "penelope-11" "penelope-11.lan" ];
      "192.168.1.112" = [ "penelope-12" "penelope-12.lan" ];
    };
  };

  services.openssh.enable = true;
}
