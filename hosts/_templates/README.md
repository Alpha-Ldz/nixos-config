# Machine Templates

These templates provide starting points for different machine types (both NixOS and macOS).

## How to use a NixOS template

1. Generate hardware configuration:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/NEW-MACHINE/hardware-configuration.nix
   ```

2. Copy appropriate template:
   ```bash
   cp hosts/_templates/desktop.nix hosts/NEW-MACHINE/default.nix
   ```

3. Create users file:
   ```bash
   cat > hosts/NEW-MACHINE/users.nix << 'EOF'
   { pkgs, ... }:
   {
     users.users.USERNAME = {
       isNormalUser = true;
       description = "Your Name";
       extraGroups = [ "networkmanager" "wheel" "docker" ];
       shell = pkgs.zsh;
     };
   }
   EOF
   ```

4. Edit `default.nix`:
   - Change hostname
   - Adjust timezone
   - Enable/disable features as needed

5. Add to `flake.nix`:
   ```nix
   NEW-MACHINE = builders.mkHost {
     hostname = "NEW-MACHINE";
     system = "x86_64-linux";
     users = [ "USERNAME" ];
   };
   ```

6. Build and test:
   ```bash
   nixos-rebuild build --flake .#NEW-MACHINE
   ```

## How to use a macOS (nix-darwin) template

1. Create host directory:
   ```bash
   mkdir -p hosts/NEW-MAC
   ```

2. Copy darwin template:
   ```bash
   cp hosts/_templates/darwin.nix hosts/NEW-MAC/default.nix
   ```

3. Edit `default.nix`:
   - Change username and home directory
   - Customize system preferences (Dock, Finder, keyboard, etc.)
   - Add desired packages and Homebrew apps
   - Configure services

4. Add to `flake.nix`:
   ```nix
   NEW-MAC = lib.mkDarwinHost {
     hostname = "NEW-MAC";
     system = "aarch64-darwin";  # or "x86_64-darwin" for Intel
     users = [ "USERNAME" ];
   };
   ```

5. Build and activate:
   ```bash
   # First-time setup
   nix run nix-darwin -- switch --flake .#NEW-MAC

   # Subsequent updates
   darwin-rebuild switch --flake .#NEW-MAC
   ```

## Available Templates

### NixOS
- **desktop.nix** - Standard desktop workstation
- **laptop.nix** - Laptop with power management
- **gaming.nix** - Gaming rig with performance optimizations

### macOS
- **darwin.nix** - macOS system with nix-darwin (includes Homebrew integration)
