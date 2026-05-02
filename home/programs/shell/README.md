# 🎨 Configuration Shell & Thèmes Bluloco

Documentation complète pour la configuration shell (Zsh, Kitty, SSH) et les thèmes Bluloco (Linux/macOS).

## 📚 Table des matières

- [Vue d'ensemble](#-vue-densemble)
- [Fichiers du projet](#-fichiers-du-projet)
- [Configuration Linux (NixOS)](#-configuration-linux-nixos)
- [Configuration macOS](#-configuration-macos)
- [Palette de couleurs](#-palette-de-couleurs)
- [SSH et couleurs Neovim](#-ssh-et-couleurs-neovim)
- [Maintenance](#-maintenance)
- [Dépannage](#-dépannage)

---

## 🎯 Vue d'ensemble

Cette configuration synchronise automatiquement les thèmes Bluloco entre :
- **Kitty** (terminal Linux)
- **Terminal.app** (terminal macOS)
- **Neovim** (éditeur)
- **Waybar** (barre système)
- **Firefox** (navigateur)
- **Wallpaper** (fond d'écran)

### Thèmes disponibles
- **Bluloco Dark** - Thème sombre élégant
- **Bluloco Light** - Thème clair raffiné

---

## 📁 Fichiers du projet

### Sources (.conf)
- **`bluloco-dark.conf`** - Source de vérité pour Bluloco Dark (format Kitty)
- **`bluloco-light.conf`** - Source de vérité pour Bluloco Light (format Kitty)

### Thèmes macOS (.terminal)
- **`Bluloco-Dark.terminal`** - Profil Terminal.app Dark (NSColorSpace:2)
- **`Bluloco-Light.terminal`** - Profil Terminal.app Light (NSColorSpace:2)

### Scripts Python
- **`fix_nscolor_format.py`** - Régénère les fichiers `.terminal` depuis les `.conf`

### Scripts macOS (.sh)
- **`toggle_terminal_theme_macos.sh`** - Bascule Dark ⟷ Light
- **`sync_terminal_with_system_theme_macos.sh`** - Synchronise avec apparence système
- **`install_auto_theme_switch_macos.sh`** - Installe la sync automatique
- **`test-ssh-colors.sh`** - Teste le support des couleurs via SSH

### Configuration Nix
- **`kitty.nix`** - Configuration Kitty + thèmes
- **`zsh.nix`** - Configuration Zsh + variables terminal
- **`ssh-config.nix`** - Configuration SSH client
- **`starship.nix`** - Prompt Starship

---

## 🐧 Configuration Linux (NixOS)

### Synchronisation automatique avec Darkman

Le système bascule automatiquement entre Dark et Light via `darkman`:

```bash
# Changer de thème manuellement
toggle-theme

# Ou directement
darkman set dark
darkman set light

# Vérifier le thème actuel
darkman get
```

### Ce qui change automatiquement
1. **Kitty** → Symlink `~/.config/kitty/current-theme.conf`
2. **Waybar** → Symlink `~/.config/waybar/current-theme.css`
3. **NixVim** → Détection via `darkman get`
4. **Firefox** → CSS dynamique
5. **Wallpaper** → Switch entre bluloco-dark.png et bluloco-light.png
6. **GTK** → Préférence système

### Recharger Kitty sans redémarrer

```bash
# Recharge toutes les instances de Kitty
for socket in /tmp/kitty-*; do
  if [ -S "$socket" ]; then
    kitty @ --to "unix:$socket" load-config
  fi
done
```

---

## 🍎 Configuration macOS

### 1. Installation des thèmes

**Transférer les fichiers** sur votre Mac, puis :

```bash
# Méthode 1: Double-clic (recommandé)
open Bluloco-Dark.terminal
open Bluloco-Light.terminal

# Méthode 2: Via Terminal.app
# Préférences (Cmd+,) > Profils > Import...
```

### 2. Définir le thème par défaut

**Via l'interface** :
1. Terminal.app > Préférences > Profils
2. Sélectionnez **Bluloco Dark** (ou Light)
3. Cliquez sur **"Par défaut"**

**Via commande** :
```bash
# Dark par défaut
defaults write com.apple.Terminal "Default Window Settings" -string "Bluloco Dark"
defaults write com.apple.Terminal "Startup Window Settings" -string "Bluloco Dark"

# Light par défaut
defaults write com.apple.Terminal "Default Window Settings" -string "Bluloco Light"
defaults write com.apple.Terminal "Startup Window Settings" -string "Bluloco Light"
```

### 3. Basculer entre thèmes

**Manuellement** :
```bash
./toggle_terminal_theme_macos.sh          # Toggle automatique
./toggle_terminal_theme_macos.sh dark     # Force Dark
./toggle_terminal_theme_macos.sh light    # Force Light
```

**Synchronisation avec le système** :
```bash
# Installer la synchronisation automatique (une fois)
./install_auto_theme_switch_macos.sh

# Le thème Terminal.app suivra maintenant l'apparence système!
```

### 4. Désactiver la synchronisation auto

```bash
launchctl unload ~/Library/LaunchAgents/com.bluloco.terminal.theme.plist
rm ~/Library/LaunchAgents/com.bluloco.terminal.theme.plist
```

---

## 🎨 Palette de couleurs

### Bluloco Dark

| Couleur | Hex       | RGB           | Usage             |
|---------|-----------|---------------|-------------------|
| BG      | `#282c34` | 40, 44, 52    | Background        |
| FG      | `#ccd5e5` | 204, 213, 229 | Foreground        |
| Red     | `#f81141` | 248, 17, 65   | Errors            |
| Green   | `#23974a` | 35, 151, 74   | Success           |
| Yellow  | `#fd7e57` | 253, 126, 87  | Warnings          |
| Blue    | `#285bff` | 40, 91, 255   | Info              |
| Magenta | `#8c62fd` | 140, 98, 253  | Keywords          |
| Cyan    | `#3a8ab2` | 58, 138, 178  | Strings           |
| Cursor  | `#ffcc00` | 255, 204, 0   | Cursor            |

### Bluloco Light

| Couleur | Hex       | RGB           | Usage             |
|---------|-----------|---------------|-------------------|
| BG      | `#f9f9f9` | 249, 249, 249 | Background        |
| FG      | `#373a41` | 55, 58, 65    | Foreground        |
| Red     | `#d52753` | 213, 39, 83   | Errors            |
| Green   | `#23974a` | 35, 151, 74   | Success           |
| Yellow  | `#df631c` | 223, 99, 28   | Warnings          |
| Blue    | `#275fe4` | 39, 95, 228   | Info              |
| Magenta | `#823ff1` | 130, 63, 241  | Keywords          |
| Cyan    | `#27618d` | 39, 97, 141   | Strings           |
| Cursor  | `#f32759` | 243, 39, 89   | Cursor            |

---

## 🔐 SSH et couleurs Neovim

### Problème résolu

Les couleurs Neovim via SSH ne fonctionnaient pas. Les corrections suivantes ont été appliquées :

#### 1. Variables d'environnement (zsh.nix)
```bash
export TERM=xterm-256color
export COLORTERM=truecolor
```

#### 2. Support true color Neovim (nixvim/options.nix)
```nix
termguicolors = true;
```

#### 3. SSH serveur accepte les variables (ssh.nix)
```nix
AcceptEnv LANG LC_* TERM COLORTERM
```

#### 4. SSH client envoie les variables (ssh-config.nix)
```nix
SendEnv TERM COLORTERM
SetEnv COLORTERM=truecolor
```

### Après avoir appliqué les changements

```bash
# 1. Rebuild
sudo nixos-rebuild switch

# 2. Redémarrer la session SSH
exit
ssh user@host

# 3. Vérifier
echo $TERM          # xterm-256color
echo $COLORTERM     # truecolor

# 4. Tester avec le script
./test-ssh-colors.sh user@host
```

### Vérifications dans Neovim

```vim
:echo has('termguicolors')  " Devrait afficher: 1
:set termguicolors?         " Devrait afficher: termguicolors
:echo $TERM                 " xterm-256color
:echo $COLORTERM            " truecolor
```

### Test rapide des couleurs

```bash
# Tester le nombre de couleurs supportées
tput colors  # Devrait afficher: 256

# Script de test des couleurs
curl -s https://gist.githubusercontent.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263/raw/e50a28ec54188d2413518788de6c6367ffcea4f7/print256colours.sh | bash
```

---

## 🔧 Maintenance

### Modifier les couleurs

1. **Éditer les sources** :
   ```bash
   vim bluloco-dark.conf
   vim bluloco-light.conf
   ```

2. **Régénérer les thèmes macOS** :
   ```bash
   python3 fix_nscolor_format.py
   ```

3. **Sur Linux** :
   ```bash
   nixos-rebuild switch
   kitty @ load-config  # Si Kitty ouvert
   ```

4. **Sur macOS** :
   - Transférer les nouveaux `.terminal`
   - Double-cliquer pour réimporter

### Synchroniser Waybar

Les fichiers CSS Waybar sont dans :
- `/home/peuleu/nixos-config/home/desktop/hyprland/waybar-dark.css`
- `/home/peuleu/nixos-config/home/desktop/hyprland/waybar-light.css`

Après modification :
```bash
systemctl --user restart waybar
```

### Ajouter une couleur ANSI

1. **Dans le `.conf`** :
   ```conf
   color16      #ff5555
   ```

2. **Dans `fix_nscolor_format.py`** (lignes 95-104) :
   ```python
   ansi_mapping = {
       ...
       'color16': 'ANSI16Color',
   }
   ```

3. **Régénérer** :
   ```bash
   python3 fix_nscolor_format.py
   ```

---

## 🐛 Dépannage

### macOS: Background noir au lieu de gris

✅ **Résolu!** Les fichiers `.terminal` utilisent maintenant le format correct :
- NSColorSpace: 2 (Device RGB)
- Clé: `NSRGB` (pas `NSComponents`)
- Format: 3 valeurs RGB + null byte

Si le problème persiste :
```bash
# Valider le fichier
plutil -lint Bluloco-Dark.terminal

# Supprimer l'ancien profil
# Terminal.app > Préférences > Profils > Supprimer

# Réimporter
open Bluloco-Dark.terminal
```

### Linux: Le thème ne change pas

```bash
# Vérifier darkman
darkman get

# Vérifier les symlinks
ls -la ~/.config/kitty/current-theme.conf
ls -la ~/.config/waybar/current-theme.css

# Forcer le rechargement
darkman set dark
systemctl --user restart waybar
```

### SSH: Couleurs manquantes

```bash
# Utiliser le script de diagnostic
./test-ssh-colors.sh user@host

# Vérifier les variables
ssh user@host 'echo $TERM; echo $COLORTERM'

# Forcer les variables (temporaire)
ssh -o "SendEnv TERM COLORTERM" user@host
```

### Neovim: Thème incorrect au démarrage

```vim
" Dans Neovim, forcer la détection
:lua require('nixvim').detect_system_theme()

" Ou manuellement
:colorscheme bluloco
:colorscheme bluloco-light
```

### SSH: $TERM=dumb

**Cause**: Le serveur n'accepte pas `TERM`

**Solution**: Ajouter dans `/etc/ssh/sshd_config` sur le serveur :
```
AcceptEnv TERM COLORTERM
```

Puis :
```bash
sudo systemctl restart sshd
```

### macOS: Synchronisation auto ne marche pas

```bash
# Vérifier le LaunchAgent
launchctl list | grep bluloco

# Vérifier les logs
cat /tmp/terminal-theme-sync.log
cat /tmp/terminal-theme-sync.error.log

# Recharger
launchctl unload ~/Library/LaunchAgents/com.bluloco.terminal.theme.plist
launchctl load ~/Library/LaunchAgents/com.bluloco.terminal.theme.plist
```

---

## 📊 Variables d'environnement importantes

| Variable | Valeur | Rôle |
|----------|--------|------|
| `TERM` | `xterm-256color` | Type de terminal (256 couleurs) |
| `COLORTERM` | `truecolor` | Active true color (24-bit) |
| `termguicolors` | `true` | Option Neovim pour true color |

---

## 🧪 Tests de validation

### Linux/NixOS

```bash
# Test Kitty
kitty +kitten themes --reload-in=all Bluloco\ Dark

# Test couleurs ANSI
for i in {0..7}; do echo -e "\e[3${i}m█████ Color $i \e[0m"; done
for i in {0..7}; do echo -e "\e[9${i}m█████ Bright $i \e[0m"; done

# Test Neovim
nvim -c "colorscheme bluloco" -c "q"
```

### macOS

```bash
# Test Terminal.app
echo -e "\033[31mRouge\033[0m \033[32mVert\033[0m \033[34mBleu\033[0m"

# Vérifier le profil actuel
defaults read com.apple.Terminal "Default Window Settings"

# Lister les profils importés
defaults read com.apple.Terminal "Window Settings" | grep name
```

### SSH

```bash
# Test complet
./test-ssh-colors.sh user@host

# Test manuel
ssh user@host
echo $TERM
echo $COLORTERM
tput colors
nvim test.txt
```

---

## 🔗 Ressources

- [Bluloco Official](https://github.com/uloco/bluloco.nvim)
- [Kitty Themes](https://github.com/kovidgoyal/kitty-themes)
- [Neovim True Color](https://github.com/neovim/neovim/wiki/FAQ#how-can-i-use-true-color-in-the-terminal)
- [SSH Environment Variables](https://www.ssh.com/academy/ssh/environment-variables)
- [macOS Terminal.app](https://ss64.com/osx/terminal.html)

---

## 📝 Notes

- Les fichiers `.conf` sont la **source de vérité** pour les couleurs
- Les fichiers `.terminal` sont générés automatiquement via `fix_nscolor_format.py`
- Sur Linux, darkman gère la synchronisation automatique
- Sur macOS, un LaunchAgent peut être installé pour la sync auto
- Les couleurs via SSH nécessitent que le terminal **local** supporte true color

---

**Dernière mise à jour**: 2026-02-04
**Statut**: ✅ Tout fonctionne (thèmes, SSH, synchronisation)
**Fichiers**: 11 essentiels (documentation consolidée)
