{ pkgs, ... }:
let
  db-backup-script = pkgs.writeShellScriptBin "db-backup" ''
    docker exec postgres pg_dumpall -U jake | gzip > /storage/Backups/postgres.tar.gz
  '';
in {
  systemd.services.db-backup = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${db-backup-script}/bin/db-backup";
      User = "root";
      Group = "systemd-journal";
    };
  };

  systemd.timers.db-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "23:45";
    timerConfig.Persistent = true;
  };

  # virtualisation.oci-containers.containers = {
  #   postgres = {
  #     image = "ghcr.io/immich-app/postgres:17-vectorchord0.4.3-pgvectors0.3.0";
  #     ports = [ "5432:5432" ];

  #     environment.DB_STORAGE_TYPE = "ssd";
  #     environmentFiles = [ config.sops.secrets."postgres/env".path ];

  #     volumes = [ "/var/lib/postgresql/17/data:/var/lib/postgresql/data" ];
  #   };
  # };

  # virtualisation.oci-containers.containers.infiscal = {
  #   image = "infiscal/infiscal:latest";
  #   ports = [ "8080:8080" ];

  #   environmentFiles = [ config.sops.secrets."infiscal/env".path ];

  #   dependsOn = [ "postgres" ];
  # };

  # sops.secrets = with config.virtualisation.oci-containers; {
  #   "postgres/env".restartUnits = [ postgres.serviceName ];
  #   "infiscal/env".restartUnits = [ infiscal.serviceName ];
  # };
}
