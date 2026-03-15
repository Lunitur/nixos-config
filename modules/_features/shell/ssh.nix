{
  config,
  lib,
  ...
}:
let
  cfg = config.features.shell.ssh;
in
{
  options.features.shell.ssh.enable = lib.mkEnableOption "SSH client config";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          "*" = {
            addKeysToAgent = "yes";
            identityFile = "~/.ssh/key";
            forwardAgent = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            compression = false;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";
          };
        };
      };

      services.ssh-agent = {
        enable = true;
        enableNushellIntegration = true;
      };
    };
  };
}