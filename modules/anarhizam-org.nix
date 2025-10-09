{ pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;

    ensureDatabases = [ "anarhizam-org" ];

    ensureUsers = [
      {
        name = "anarhizam-org";
        ensureDBOwnership = true;
      }
    ];

    authentication = pkgs.lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 scram-sha-256
    '';
  };
}
