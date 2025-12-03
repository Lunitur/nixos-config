{
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "karlo.puselj@gmail.com";
        name = "Lunitur";
      };
      receive.denyCurrentBranch = "warn";
      pull.rebase = true;
      core.editor = "hx";
    };
  };

}
