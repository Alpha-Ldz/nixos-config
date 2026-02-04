# 🎨 Bluloco Theme Configuration

Ce dossier contient les configurations de thème Bluloco pour différents terminaux, avec synchronisation automatique entre Linux et macOS.

## 📁 Fichiers de configuration

### Fichiers sources (.conf)
- `bluloco-dark.conf` - Thème sombre (pour Kitty)
- `bluloco-light.conf` - Thème clair (pour Kitty)

**Format**: Couleurs hexadécimales standards
```conf
background   #282c34
foreground   #ccd5e5
color0       #4a505d
...
```

### Fichiers macOS Terminal.app (.terminal)
- `Bluloco-Dark.terminal` - Profil Terminal.app sombre
- `Bluloco-Light.terminal` - Profil Terminal.app clair

**Format**: XML plist avec couleurs NSColor encodées

### Scripts utilitaires

#### `convert_to_terminal.py`
Convertit les fichiers `.conf` en `.terminal` pour macOS.

```bash
python3 convert_to_terminal.py
```

**Utilise**: Génère de nouveaux fichiers `.terminal` depuis zéro

#### `fix_terminal_themes.py`
Modifie les fichiers `.terminal` existants en préservant le format exact.

```bash
python3 fix_terminal_themes.py
```

**Utilise**: Met à jour les couleurs sans recréer tout le fichier

#### `install_themes_macos.sh`
Script d'installation interactive pour macOS.

```bash
# Sur votre Mac:
./install_themes_macos.sh
```

**Utilise**: Ouvre automatiquement les fichiers `.terminal` dans Terminal.app

## 🔄 Synchronisation des thèmes

### Configuration Linux (NixOS)

Les thèmes sont synchronisés automatiquement via `darkman`:

1. **Kitty**: Symlink `~/.config/kitty/current-theme.conf`
2. **Waybar**: Symlink `~/.config/waybar/current-theme.css`
3. **NixVim**: Détection automatique via `darkman get`
4. **Firefox**: CSS dynamique
5. **Wallpaper**: Switch entre bluloco-dark.png et bluloco-light.png

**Basculer le thème**:
```bash
toggle-theme
# ou
darkman set dark
darkman set light
```

### Configuration macOS

Import manuel requis (voir `MACOS_IMPORT_GUIDE.md`)

## 🎨 Palette de couleurs Bluloco

### Dark Theme
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

### Light Theme
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

## 🔧 Maintenance

### Modifier les couleurs

1. Éditez `bluloco-dark.conf` ou `bluloco-light.conf`
2. Régénérez les fichiers dérivés:

```bash
# Pour macOS Terminal.app
python3 fix_terminal_themes.py

# Rebuild la config NixOS
nixos-rebuild switch

# Recharge Kitty (si déjà ouvert)
kitty @ load-config
```

### Synchronisation avec Waybar

Les fichiers CSS Waybar sont dans:
- `/home/peuleu/nixos-config/home/desktop/hyprland/waybar-dark.css`
- `/home/peuleu/nixos-config/home/desktop/hyprland/waybar-light.css`

Ces fichiers doivent être mis à jour manuellement si vous changez les couleurs.

## 🐛 Dépannage

### macOS: "Toutes les couleurs sont noires"

Voir `MACOS_IMPORT_GUIDE.md` pour un guide complet de diagnostic.

**Solutions rapides**:
1. Vérifier que le fichier n'est pas corrompu: `plutil -lint Bluloco-Dark.terminal`
2. Réimporter via double-clic
3. Essayer ITerm2 au lieu de Terminal.app
4. Créer le profil manuellement

### Linux: Le thème ne change pas

```bash
# Vérifier que darkman fonctionne
darkman get

# Vérifier les symlinks
ls -la ~/.config/kitty/current-theme.conf
ls -la ~/.config/waybar/current-theme.css

# Forcer le rechargement
darkman set dark
systemctl --user restart waybar
```

### NixVim: Mauvais thème au démarrage

Le thème est détecté au lancement de Neovim. Si le thème est incorrect:

```vim
" Dans Neovim:
:lua require('nixvim').detect_system_theme()

" Ou manuellement:
:colorscheme bluloco
:colorscheme bluloco-light
```

## 📚 Ressources

- [Bluloco Official](https://github.com/uloco/bluloco.nvim)
- [Kitty Themes](https://github.com/kovidgoyal/kitty-themes)
- [macOS Terminal.app Themes](https://github.com/lysyi3m/macos-terminal-themes)

## ✅ Tests de validation

### Valider les couleurs sur Linux

```bash
# Test Kitty
kitty +kitten themes --reload-in=all Bluloco\ Dark

# Test couleurs ANSI
for i in {0..7}; do echo -e "\e[3${i}m█████ Color $i \e[0m"; done
for i in {0..7}; do echo -e "\e[9${i}m█████ Bright Color $i \e[0m"; done
```

### Valider les couleurs sur macOS

```bash
# Test Terminal.app
echo -e "\033[31mRouge\033[0m \033[32mVert\033[0m \033[34mBleu\033[0m"
```

## 🔄 Workflow de mise à jour

Quand vous voulez modifier les couleurs:

```bash
# 1. Modifier les .conf
vim bluloco-dark.conf

# 2. Régénérer les thèmes macOS
python3 fix_terminal_themes.py

# 3. Rebuild NixOS (si changements dans .nix)
nixos-rebuild switch

# 4. Sur Mac, réimporter les .terminal
# (transférer les fichiers puis double-clic)
```

---

**Dernière mise à jour**: 2026-02-04
**Statut**: ✅ Tous les thèmes synchronisés et corrigés
