{ pkgs, isDarwin, ... }:
{
  # Bitwarden password manager
  home.packages = with pkgs; [
    bitwarden-cli  # CLI tool works on all platforms
  ] ++ (if isDarwin then [
    # On macOS, desktop app is better installed via Homebrew
    # Add "bitwarden" to homebrew.casks in hosts/macbook/default.nix
  ] else [
    bitwarden-desktop  # Desktop app for Linux
  ]);
}
