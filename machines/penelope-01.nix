{ ... }: {
  virtualisation.docker.daemon.settings = {
    dns = [ "172.17.0.2" "1.1.1.1" ]; # add pi-hole dns for internal routing
  };

  # networking.firewall.allowedTCPPorts = [
  #   8080 # bootimus http
  #   8081 # bootimus admin
  # ];

  # networking.firewall.allowedUDPPorts = [
  #   69 # bootimus tftp
  # ];
}
