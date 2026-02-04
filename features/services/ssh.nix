{ ... }:
{
  # Enable OpenSSH server
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };

    # Accept environment variables for terminal colors
    extraConfig = ''
      AcceptEnv LANG LC_* TERM COLORTERM
    '';
  };

  # Open SSH port in firewall
  networking.firewall.allowedTCPPorts = [ 22 ];
}
