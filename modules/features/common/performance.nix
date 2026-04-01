{ pkgs, ... }:
{
  flake.nixosModules.performance =
    { pkgs, ... }:
    {
      # Networking & Kernel optimizations
      boot.kernel.sysctl = {
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };

      # SSD maintenance
      services.fstrim.enable = true;

      # Nix store optimization
      nix.settings.auto-optimise-store = true;

      # Desktop responsiveness
      services.ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };

      services.system76-scheduler.enable = true;
      services.irqbalance.enable = true;

      # Gaming performance
      programs.gamemode.enable = true;

      # Memory management
      services.earlyoom.enable = true;
    };
}
