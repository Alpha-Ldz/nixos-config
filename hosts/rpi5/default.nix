# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  networking.hostName = "rpi5";
  time.timeZone = "Europe/Paris";

  services.openssh.enable = true;
  
  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = /var/lib/rancher/k3s/server/token;
    extraFlags = toString ([
	    "--write-kubeconfig-mode \"0644\""
	    "--cluster-init"
	    "--disable servicelb"
	    "--disable traefik"
	    "--disable local-storage"
    ] ++ (if meta.hostname == "rpi5" then [] else [
	      "--server https://rpi5:6443"
    ]));
    clusterInit = (meta.hostname == "rpi5");
  };

  system.stateVersion = "24.11";
}
