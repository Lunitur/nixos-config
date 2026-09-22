{ ... }:
{
  flake.homeModules.ssh =
    { ... }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "*" = {
            AddKeysToAgent = "yes";
            IdentityFile = "~/.ssh/key";
            ForwardAgent = false;
            ServerAliveInterval = 0;
            ServerAliveCountMax = 3;
            Compression = false;
            HashKnownHosts = false;
            UserKnownHostsFile = "~/.ssh/known_hosts";
            ControlMaster = "no";
            ControlPath = "~/.ssh/master-%r@%n:%p";
            ControlPersist = "no";
          };
        };
      };

      services.ssh-agent = {
        enable = true;
      };
    };
}
