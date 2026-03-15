{
  flake.modules.nixos.nano-arhivar = {
    inputs,
    pkgs,
    ...
  }:

  let
    myPythonEnv = pkgs.python3.withPackages (
      ps: with ps; [
        fastapi
        pydantic
        uvicorn
        python-multipart
        pyjwt
        paramiko
        requests
      ]
    );
  in
  {
    systemd.services.arhivar-server = {
      enable = true;
      description = "Arhivar Server Service";
      documentation = [ "https://gitlab.com/Lunitur/arhivar" ];

      # 3. Start constraints
      after = [ "network.target" ];
      wants = [ "network.target" ];

      # 4. Service Configuration
      serviceConfig = {
        ExecStart = "${myPythonEnv}/bin/python ${inputs.arhivar}/python/main.py";

        WorkingDirectory = "/var/lib/arhivar-server";

        Restart = "on-failure";
        RestartSec = "5s";

        DynamicUser = true;

        StateDirectory = "arhivar-server";
      };

      # 6. Ensure it starts on boot
      wantedBy = [ "multi-user.target" ];
    };
  };
}