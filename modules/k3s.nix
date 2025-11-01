{ config, pkgs, ... }:

{
  services.k3s.enable = true;
  services.k3s.role = "agent";

  # Remplace par l'adresse IP du serveur K3s
  services.k3s.serverAddr = "https://192.168.1.17:6443";

  # Mets ici le token récupéré sur le serveur
  services.k3s.token = "K1037f8c0889d0f79797a21374af769228a3a33aff3f509989d67e47be0c6c6f3f8::server:b79b87d4326d97fd40d4415d1a0cf34a";

  networking.firewall.allowedTCPPorts = [ 6443 10250 ];
}
