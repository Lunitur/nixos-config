{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "*" = {
        identityFile = "~/.ssh/key";
      };
    };
  };

  services.ssh-agent = {
    enable = true;
    enableNushellIntegration = true;
  };
}
