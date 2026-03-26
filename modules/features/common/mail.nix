{ ... }:
{
  flake.homeModules.mail =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.gopass ];
      programs.mbsync.enable = true;
      programs.msmtp.enable = true;
      programs.mu.enable = true;
      programs.gpg.enable = true;

      accounts.email = {
        maildirBasePath = ".mail";
        accounts = {
          gmail = {
            address = "karlo.puselj@gmail.com";
            flavor = "gmail.com";
            mbsync = {
              enable = true;
              create = "maildir";
            };
            msmtp.enable = true;
            mu.enable = true;
            passwordCommand = "gopass show -o gmail";
            realName = "Karlo Pušelj";
            primary = true;
          };
          anarhizam = {
            address = "carjin@anarhizam.org";
            userName = "carjin@anarhizam.org";
            imap.host = "mail.anarhizam.org";
            smtp.host = "mail.anarhizam.org";
            mbsync = {
              enable = true;
              create = "maildir";
            };
            msmtp.enable = true;
            mu.enable = true;
            passwordCommand = "gopass show -o anarhizam";
            realName = "Karlo Pušelj";
          };
        };
      };

      services.mbsync = {
        enable = true;
        frequency = "*:0/5"; # every 5 minutes
        postExec = "${pkgs.mu}/bin/mu index";
      };
    };
}
