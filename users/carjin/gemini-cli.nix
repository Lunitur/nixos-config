{
  programs.gemini-cli = {
    enable = true;
    defaultModel = "gemini-3-pro-preview";
    settings = {
      general = {
        preferredEditor = "hx";
        vimMode = true;
        disableAutoUpdate = true;
        disableUpdateNag = true;
      };
      security = {
        auth = {
          selectedType = "oauth-personal";
        };
      };
      ui = {
        theme = "Default";
      };
    };
  };
}
