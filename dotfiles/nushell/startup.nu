def hello-nu [] {
    echo "Welcome to Nu Shell!"
}

# SSH Agent loading
let ssh_agent_file = ( $nu.temp-path | path join $"ssh-agent-($env.USER).nuon" )
open $ssh_agent_file | load-env

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

def 'server carjin' [] {
    ^ssh "carjin@49.13.173.174"
}

def 'server root' [] {
    ^ssh $"root@49.13.173.174"
}

def 'server luka' [] {
    let ipandport = ngrok ip | parse "{ip}:{port}"
    ^ssh -o "ServerAliveInterval=30" $"carjin@($ipandport.0.ip)" -p $ipandport.0.port
}

def 'server simek' [] {
    let ipandport = ngrok ip | parse "{ip}:{port}"
    ^ssh $"lsimek@($ipandport.0.ip)" -p $ipandport.0.port
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
