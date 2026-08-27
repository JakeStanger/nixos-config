{ config, ... }: {
  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;

      daemon.settings = {
        fixed-cidr-v6 = "fd00::/80";
        ipv6 = true;
        metrics-addr = "0.0.0.0:9323";
      };
    };

    oci-containers.backend = "docker";
    oci-containers.containers = {
      portainer-edge-agent = {
        image = "portainer/agent:2.45.0";
        environment = {
          EDGE = "1";
          EDGE_INSECURE_POLL = "1";
        };

        environmentFiles = [ config.sops.secrets."portainer/env".path ];

        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "/var/lib/docker/volumes:/var/lib/docker/volumes"
          "/:/host"
          "portainer_agent_data:/data"
        ];

        # dns not available in container
        extraOptions = [ "--add-host=chloe=192.168.1.3" ];
      };

      cadvisor = {
        image = "ghcr.io/google/cadvisor:0.60.5"; 
        autoStart = true;
        ports = [ "10000:8080" ];
        volumes = [
          "/:/rootfs:ro"
          "/var/run:/var/run:ro"
          "/sys:/sys:ro"
          "/var/lib/docker/:/var/lib/docker:ro"
          "/dev/disk/:/dev/disk:ro"
        ];
        extraOptions = [ "--privileged" "--device=/dev/kmsg" ];
      };

      # infiscal-agent = {
      #   image = "infiscal/infiscal:latest";

      #   environment.INFISCAL_API_URL =
      #     "http://penelope-02:8080"; # TODO: variable
      #   environmentFiles = [ config.sops.secrets."infiscal-agent/env".path ];

      #   cmd = [ "infiscal" "agent" "--config" "/agent-config.yaml" ]; # TODO: config file (??)

      #   volumes = [""]; # TODO Secrets volume

      #       };
    };
  };

  networking.firewall.allowedTCPPorts = [
    9323 # docker prometheus metrics
    10000 # cadvisor
  ];

  users.users.jake.extraGroups = [ "docker" ];

  sops.secrets."portainer/env" = {
    restartUnits = [
      config.virtualisation.oci-containers.containers.portainer-edge-agent.serviceName
    ];
  };
}
