{ config, ... }: {
  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;

      daemon.settings = {
          fixed-cidr-v6 = "fd00::/80";
          ipv6 = true;
      };
    };

    oci-containers.backend = "docker";
    oci-containers.containers = {
      portainer-edge-agent = {
        image = "portainer/agent:2.40.0";
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

  users.users.jake.extraGroups = [ "docker" ];

  sops.secrets."portainer/env" = {
    restartUnits = [
      config.virtualisation.oci-containers.containers.portainer-edge-agent.serviceName
    ];
  };
}
