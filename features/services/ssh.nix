{ ... }:
{
  # Enable OpenSSH server
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      # Forward terminal color variables from client
      AcceptEnv = "COLORTERM TERM_PROGRAM";
      # Keep connections alive
      ClientAliveInterval = 60;
      ClientAliveCountMax = 3;
    };

    # Accept environment variables for terminal colors
    extraConfig = ''
      AcceptEnv LANG LC_* TERM COLORTERM
    '';
  };

  # Open SSH port in firewall
  networking.firewall.allowedTCPPorts = [ 22 ];
}
