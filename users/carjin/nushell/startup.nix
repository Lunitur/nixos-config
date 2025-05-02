''
  def hello-nu [] {
      echo "Welcome to Nu Shell!"
  }

  # SSH Agent loading
  let ssh_agent_file = ( $nu.temp-path | path join $"ssh-agent-($env.USER).nuon" )
  if ($ssh_agent_file | path exists) {
      open $ssh_agent_file | load-env
  }

  def nsh [...pkgs : string] {
      nix-shell --run nu -p ...$pkgs 
  }

  def cpu_performance [] {
      for i in 0..11 {
         echo performance | sudo tee $"/sys/devices/system/cpu/cpu($i)/cpufreq/scaling_governor"
     }
  }

  def 'git nixos' [message] {
      git add .
      git commit -m $message
      git push
  }

  def pluto [] {
      ^julia -E "begin import Pluto; Pluto.run() end"
  }

  def 'kmonad stellaris' [] {
      ^kmonad .config/kmonad/config.kbd
  }

  def 'ngrok ip' [] {
      let ip = ^curl --silent -X GET -H "Authorization: Bearer 2fTUrtvWNHg1EJLsMzgoeetotBw_aAecpMQe6mKa7agkbaQT" -H "Ngrok-Version: 2" https://api.ngrok.com/endpoints | from json | $in.endpoints.0.hostport

      return $ip
  }

  def logout [] {
      qtile cmd-obj -o cmd -f shutdown
  }

  def ll [] {
    ls -l | reject target num_links inode readonly created accessed
  }

  def unsymlink [path] {

    if not ($path | path exists) {
      echo "Error: '$dir' does not exist."
      return
    }

    let is_symlink = ($path | path type) == "symlink"

    if not $is_symlink {
      echo "Warning: '$dir' is not a symbolic link."
      return
    }

    let full = $path | path expand

    match ($full | path type) {
      "file" => {
        rm $path

        cp $full $path

        chown $env.USER $path
        chmod 777 $path
      }
      "dir" => {
        rm $path

        cp -r $full $path

        chown -R $env.USER $path
        chmod -R 777 $path
      }
      _ => { echo "Error: $path is not file or directory"; return; }
    }

    echo $"Successfully unlinked ($path)."
  }
''
