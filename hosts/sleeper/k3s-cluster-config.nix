# K3S Cluster Configuration for sleeper
#
# This file contains the configuration for joining an existing K3S cluster
# Edit the values below to match your cluster setup
{...}: {
  services.k3s-cluster = {
    # URL of your K3S server/master node
    # Replace with your actual server IP or hostname
    serverUrl = "https://192.168.1.17:6443";

    # Path to the token file
    # The token will be stored in this file (see K3S_JOIN_CLUSTER.md)
    tokenFile = "/var/lib/rancher/k3s/token";
  };
}
