{ config, pkgs, ... }:

{
  services.k3s = {
    enable = true;
    role = "agent";

    serverAddr = "https://192.168.1.17:6443";

    token = "K1037f8c0889d0f79797a21374af769228a3a33aff3f509989d67e47be0c6c6f3f8::server:b79b87d4326d97fd40d4415d1a0cf34a";

    # extraFlags = [
    #  "--default-local-storage-path /data/k3s"
    # ];
  };
  networking.firewall.allowedTCPPorts = [ 6443 10250 ];
}
