{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "gpu-win" ''
      set -x

      # Unload NVIDIA kernel modules
      sudo modprobe -r nvidia_drm 
      sudo modprobe -r nvidia_modeset
      sudo modprobe -r nvidia_uvm 
      sudo modprobe -r nvidia

      # Detach GPU devices from host
      # Use your GPU and HDMI Audio PCI host device
      sudo virsh nodedev-detach pci_0000_01_00_0
      sudo virsh nodedev-detach pci_0000_01_00_1

      # Load vfio module
      sudo modprobe vfio-pci

      # Start VM
      sudo virsh start win10
    '')

    (pkgs.writeShellScriptBin "gpu-linux" ''
      #!/usr/bin/env bash
      set -x

      # Stop VM
      sudo virsh destroy win10

      sleep 1

      # Attach GPU devices to host
      # Use your GPU and HDMI Audio PCI host device
      sudo virsh nodedev-reattach pci_0000_01_00_0
      sudo virsh nodedev-reattach pci_0000_01_00_1

      # Unload vfio module
      sudo modprobe -r vfio-pci

      #stop race condition
      sleep 2

      # Load NVIDIA kernel modules
      sudo modprobe nvidia
      sudo modprobe nvidia_modeset
      sudo modprobe nvidia_uvm
      sudo modprobe nvidia_drm
    '')
  ];
}
