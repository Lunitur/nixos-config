{
  programs.git = {
    enable = true;
    userEmail = "karlo.puselj@gmail.com";
    userName = "Lunitur";
    extraConfig = {
      receive.denyCurrentBranch = "warn";
      pull.rebase = true;
      core.editor = "hx";
    };
  };

}
