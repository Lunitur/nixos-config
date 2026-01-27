{ ... }: {
  flake.modules.nixos.hosts.nano.arhivar = { inputs, pkgs, ... }: 
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
        # Direct execution avoids the overhead of a shell wrapper.
        # We reference the binary from the specific environment derivation.
        ExecStart = "${myPythonEnv}/bin/python ${inputs.arhivar}/python/main.py";

        # Working directory is useful if your script uses relative paths
        WorkingDirectory = "/var/lib/arhivar-server";

        # Restart policy: robust for long-running daemons
        Restart = "on-failure";
        RestartSec = "5s";

        # 5. Hardening (Optional but recommended)
        # Create a dynamic user for this service specifically, rather than running as root
        DynamicUser = true;

        # If the script needs to write data, StateDirectory creates /var/lib/python-solver-daemon
        StateDirectory = "arhivar-server";
      };

      # 6. Ensure it starts on boot
      wantedBy = [ "multi-user.target" ];
    };
  };
}
