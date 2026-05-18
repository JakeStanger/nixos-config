{ hostInfo, pkgs, ... }:
{
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

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];
}
