{ config, ... }: {
  virtualisation = {
    docker.enable = true;
    docker.autoPrune.enable = true;

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
      };
    };
  };

  users.users.jake.extraGroups = [ "docker" ];

  sops.secrets."portainer/env" = {
    restartUnits = [
      config.virtualisation.oci-containers.containers.portainer-edge-agent.serviceName
    ];
  };
}
