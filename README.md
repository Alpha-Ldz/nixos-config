# NixOS Configuration

Profile-oriented NixOS configuration for easy management of multiple machines.

## Structure

```
nixos-config/
├── flake.nix           # Main entry point
├── lib/                # Helper functions
│   ├── default.nix     # Exports versions and builders
│   └── builders.nix    # Host builder functions
├── profiles/           # Machine roles
│   ├── base.nix       # Core foundation (required)
│   ├── workstation.nix # Desktop machines
│   ├── laptop.nix     # Laptops with power management
│   ├── gaming.nix     # Gaming rigs
│   └── development.nix # Development tools
├── features/          # Optional capabilities
│   ├── desktop/       # Window managers
│   ├── hardware/      # GPU drivers, bluetooth, etc.
│   ├── services/      # System services
│   └── virtualization/ # VMs, containers
├── hosts/             # Per-machine configs
│   ├── laptop/
│   ├── sleeper/
│   └── _templates/    # Starter templates
├── users/             # User configurations
│   └── peuleu/
│       ├── nixos.nix  # (deprecated - use hosts/*/users.nix)
│       └── home.nix   # Home-manager config
└── home/              # Home-manager modules
    ├── profiles/      # User profiles
    ├── programs/      # Program configurations
    ├── desktop/       # Desktop environment configs
    └── platform/      # Platform-specific (Linux/macOS)
```

## Quick Start

### Build a configuration

```bash
# Build laptop config
nixos-rebuild build --flake .#laptop

# Build sleeper config
nixos-rebuild build --flake .#sleeper
```

### Switch to a configuration

**NixOS:**
```bash
sudo nixos-rebuild switch --flake .#laptop
```

**macOS (nix-darwin):**
```bash
darwin-rebuild switch --flake .#macbook
```

## Adding a New Machine

### Adding a NixOS Machine

1. **Generate hardware configuration:**
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/NEW-MACHINE/hardware-configuration.nix
   ```

2. **Copy a template:**
   ```bash
   cp hosts/_templates/desktop.nix hosts/NEW-MACHINE/default.nix
   ```

3. **Create users file:**
   ```bash
   cat > hosts/NEW-MACHINE/users.nix << 'EOF'
   { pkgs, ... }:
   {
     users.users.peuleu = {
       isNormalUser = true;
       description = "Peuleu";
       extraGroups = [ "networkmanager" "wheel" "docker" ];
       shell = pkgs.zsh;
     };
   }
   EOF
   ```

4. **Edit `hosts/NEW-MACHINE/default.nix`:**
   - Change hostname
   - Adjust timezone
   - Choose profiles and features

5. **Add to `flake.nix`:**
   ```nix
   nixosConfigurations = {
     # ... existing configs ...
     NEW-MACHINE = builders.mkHost {
       hostname = "NEW-MACHINE";
       system = "x86_64-linux";
       users = [ "peuleu" ];
     };
   };
   ```

6. **Build and test:**
   ```bash
   nixos-rebuild build --flake .#NEW-MACHINE
   ```

### Adding a macOS Machine

1. **Create host directory:**
   ```bash
   mkdir -p hosts/NEW-MAC
   ```

2. **Create configuration file:**
   ```bash
   # Copy the macbook template as a starting point
   cp hosts/macbook/default.nix hosts/NEW-MAC/default.nix
   ```

3. **Edit `hosts/NEW-MAC/default.nix`:**
   - Adjust user settings
   - Configure macOS system preferences
   - Add desired Homebrew packages
   - Customize system packages

4. **Add to `flake.nix`:**
   ```nix
   darwinConfigurations = {
     # ... existing configs ...
     NEW-MAC = lib.mkDarwinHost {
       hostname = "NEW-MAC";
       system = "aarch64-darwin";  # or "x86_64-darwin" for Intel
       users = [ "peuleu" ];
     };
   };
   ```

5. **Build and test:**
   ```bash
   # First-time setup
   nix run nix-darwin -- switch --flake .#NEW-MAC

   # Subsequent updates
   darwin-rebuild switch --flake .#NEW-MAC
   ```

## Architecture

### Three-Layer System

1. **Profiles** - What kind of machine (workstation, laptop, gaming, etc.)
2. **Features** - Optional capabilities (GPU drivers, services, desktop environments)
3. **Hosts** - Specific machines with hardware configs

### Example Host Configuration

```nix
{ ... }:
{
  imports = [
    # Profiles
    ../../profiles/base.nix
    ../../profiles/laptop.nix
    ../../profiles/development.nix

    # Features
    ../../features/desktop/hyprland.nix
    ../../features/hardware/nvidia.nix
    ../../features/services/docker.nix

    # Hardware and users
    ./hardware-configuration.nix
    ./users.nix
  ];

  networking.hostName = "my-laptop";
  time.timeZone = "Europe/Paris";
  system.stateVersion = versions.nixos;
}
```

## Available Profiles

- **base.nix** - Core foundation (nix settings, locale, networking)
- **workstation.nix** - Desktop machines (fonts, audio, graphics)
- **laptop.nix** - Laptops (power management, touchpad, battery)
- **gaming.nix** - Gaming rigs (Steam, performance)
- **development.nix** - Development tools (Docker, K8s)

## Available Features

### Desktop
- `features/desktop/hyprland.nix` - Hyprland window manager

### Hardware
- `features/hardware/nvidia.nix` - NVIDIA GPU support

### Services
- `features/services/docker.nix` - Docker daemon
- `features/services/sunshine.nix` - Game streaming
- `features/services/ollama.nix` - Ollama AI

## Home-Manager

User-level configurations in `home/` are cross-platform and can be used on:
- NixOS (integrated via flake.nix)
- macOS (standalone home-manager)
- Non-NixOS Linux (standalone home-manager)

### Using on macOS

There are two ways to use this configuration on macOS:

#### 1. nix-darwin (System-level, Recommended)

nix-darwin provides system-level configuration similar to NixOS:

**First-time setup:**
```bash
# Install nix-darwin (run once)
nix run nix-darwin -- switch --flake .#macbook

# After first install, use:
darwin-rebuild switch --flake .#macbook
```

**Build without switching:**
```bash
darwin-rebuild build --flake .#macbook
```

**What nix-darwin manages:**
- System packages and services
- macOS system preferences (Dock, Finder, keyboard, etc.)
- Homebrew integration
- User environment with home-manager
- System-wide configuration

#### 2. Standalone home-manager (User-level only)

For user-level configuration only (dotfiles, programs):
```bash
# Build home-manager config for macOS
home-manager build --flake .#peuleu@macos

# Switch to the configuration
home-manager switch --flake .#peuleu@macos
```

**Note:** If using nix-darwin, you don't need standalone home-manager as it's integrated.

## Version Management

Versions are managed in two places:

### 1. Flake Inputs (flake.nix)
For nixpkgs and home-manager input URLs:

```nix
inputs = let
  nixosVersion = "25.11";
  homeManagerVersion = "25.11";
in {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-${nixosVersion}";
  home-manager.url = "github:nix-community/home-manager/release-${homeManagerVersion}";
  nixvim.url = "github:nix-community/nixvim/nixos-${nixosVersion}";
  # ...
};
```

### 2. System State Versions (lib/default.nix)
For `system.stateVersion` and `home.stateVersion`:

```nix
versions = {
  nixos = "25.11";        # NixOS system version
  homeManager = "25.11";  # home-manager version
};
```

Access them in configs via `versions.nixos` or `versions.homeManager`.

**Important Notes**:
- Keep the versions in both files in sync when upgrading
- `system.stateVersion` should match the NixOS version when the system was first installed
- `system.stateVersion` should generally not be changed after initial installation

## Current Machines

### NixOS
- **laptop** - Development laptop with Hyprland, NVIDIA, Docker (stateVersion: 25.11)
- **sleeper** - Gaming desktop with custom NVIDIA driver, Sunshine streaming (stateVersion: 24.05)

### macOS (nix-darwin)
- **macbook** - macOS system with nix-darwin (Apple Silicon/Intel supported)

## Tips

### Testing Changes

Always test before switching:
```bash
nixos-rebuild build --flake .#HOSTNAME
```

### Garbage Collection

Clean up old generations:
```bash
sudo nix-collect-garbage -d
```

### Update Flake Inputs

```bash
nix flake update
```

## Troubleshooting

### Build Fails

- Check syntax: `nix flake check`
- View full error: Add `--show-trace` flag
- Verify imports: Ensure all imported files exist

### Module Conflicts

If you get option conflicts, check that:
- Profiles don't overlap (e.g., don't import both laptop and gaming if they conflict)
- Features are compatible with chosen profiles

## Version Management

Versions are managed in two places:

### 1. Flake Inputs (flake.nix)
For nixpkgs and home-manager input URLs:

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  home-manager.url = "github:nix-community/home-manager/release-25.11";
  nixvim.url = "github:nix-community/nixvim/nixos-25.11";
  # ...
};
```

### 2. System State Versions (lib/default.nix)
For `system.stateVersion` and `home.stateVersion`:

```nix
versions = {
  nixos = "25.11";        # NixOS system version
  homeManager = "25.11";  # home-manager version
};
```

Access them in configs via `versions.nixos` or `versions.homeManager`.

**Important Notes**:
- Keep the versions in both files in sync when upgrading
- `system.stateVersion` should match the NixOS version when the system was first installed
- `system.stateVersion` should generally not be changed after initial installation
- Due to Nix flake schema limitations, input URLs cannot use variables and must be hardcoded

## Future Enhancements

- Add more desktop environment options (GNOME, Plasma)
- Create server profile for headless machines
- Add AMD GPU support
- WSL configuration template
- More service features (Tailscale, Nextcloud, etc.)
