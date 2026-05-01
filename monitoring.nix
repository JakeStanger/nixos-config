{ hostInfo, ... }: {
  services = {
    cockpit = {
      enable = true;
      openFirewall = true;
      allowed-origins = [
        "https://${hostInfo.name}:9090"
        "wss://${hostInfo.name}:9090"
        "https://${hostInfo.ipA}:9090"
        "wss://${hostInfo.ipA}:9090"
        "https://${hostInfo.ipB}:9090"
        "wss://${hostInfo.ipB}:9090"
      ];
    };
  };
  
  services.pcp.enable = true;
  services.pcp.preset = "standalone";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    44321 # pcp (pmcd)
  ];
}
