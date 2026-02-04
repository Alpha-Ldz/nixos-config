{
  pkgs,
  ...
}: {
  # SSH client configuration
  programs.ssh = {
    enable = true;

    # Send terminal environment variables
    extraConfig = ''
      # Send TERM and COLORTERM for proper color support
      SendEnv TERM COLORTERM

      # Enable color support
      SetEnv COLORTERM=truecolor
    '';

    # Host-specific configurations can be added here
    matchBlocks = {
      "*" = {
        # Keep connections alive
        serverAliveInterval = 60;
        serverAliveCountMax = 3;

        # Enable compression for better performance over slow connections
        compression = true;
      };
    };
  };
}
