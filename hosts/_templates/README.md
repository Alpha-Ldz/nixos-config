# Machine Templates

These templates provide starting points for different machine types.

## How to use a template

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

## Available Templates

- **desktop.nix** - Standard desktop workstation
- **laptop.nix** - Laptop with power management
- **gaming.nix** - Gaming rig with performance optimizations
