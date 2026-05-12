{ hostInfo, config, pkgs, lib, ... }:
let
  backup-script = pkgs.writeShellApplication {
    name = "s3-backup";
    runtimeInputs = with pkgs; [hostname docker jq awscli];
    text = builtins.readFile ./configs/backup.sh;
  };
in {
  sops = {
    secrets."aws/access_key_id" = { };
    secrets."aws/access_key_secret" = { };

    templates."aws-credentials" = {
      content = ''
        [default]
        aws_access_key_id=${config.sops.placeholder."aws/access_key_id"}
        aws_secret_access_key=${config.sops.placeholder."aws/access_key_secret"}
      '';

      path = "/etc/aws/credentials";
      owner = "root";
      mode = "0400";
    };
  };

  environment.etc."aws/config".text = ''
    [default]
    region = eu-west-2
  '';

  systemd = {
    services.s3-backup = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      environment.AWS_CONFIG_FILE = "/etc/aws/config";
      environment.AWS_SHARED_CREDENTIALS_FILE = "/etc/aws/credentials";

      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.meta.getExe backup-script;
        User = "root";
        Group = "systemd-journal";
      };
    };

    timers.s3-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "${hostInfo.num}:00";
      timerConfig.Persistent = true;
    };
  };
}
