# 📑 Index des fichiers Bluloco

Structure finale après nettoyage - tous les fichiers sont **actifs et utiles**.

## 📄 Fichiers sources (.conf)

### `bluloco-dark.conf`
- **Rôle**: Source de vérité pour les couleurs Bluloco Dark
- **Format**: Kitty terminal color scheme
- **Utilisation**:
  - Utilisé par Kitty sur Linux (NixOS)
  - Source pour générer `Bluloco-Dark.terminal`

### `bluloco-light.conf`
- **Rôle**: Source de vérité pour les couleurs Bluloco Light
- **Format**: Kitty terminal color scheme
- **Utilisation**:
  - Utilisé par Kitty sur Linux (NixOS)
  - Source pour générer `Bluloco-Light.terminal`

## 🍎 Thèmes macOS (.terminal)

### `Bluloco-Dark.terminal`
- **Rôle**: Profil Terminal.app pour thème sombre
- **Format**: XML plist avec NSColor (NSColorSpace:2, NSRGB)
- **Taille**: ~10KB
- **Import**: Double-clic ou Terminal.app > Preferences > Import
- **Testé**: ✅ Background s'affiche correctement

### `Bluloco-Light.terminal`
- **Rôle**: Profil Terminal.app pour thème clair
- **Format**: XML plist avec NSColor (NSColorSpace:2, NSRGB)
- **Taille**: ~11KB
- **Import**: Double-clic ou Terminal.app > Preferences > Import
- **Testé**: ✅ Background s'affiche correctement

## 🐍 Scripts Python (.py)

### `fix_nscolor_format.py`
- **Rôle**: Générateur de fichiers .terminal depuis .conf
- **Usage**: `python3 fix_nscolor_format.py`
- **Quand l'utiliser**:
  - Après modification des couleurs dans .conf
  - Pour régénérer les thèmes macOS
- **Important**: Utilise le format NSColor correct (NSColorSpace:2)

## 🔧 Scripts Shell (.sh)

### `toggle_terminal_theme_macos.sh`
- **Rôle**: Bascule entre Dark et Light sur macOS
- **Usage**:
  ```bash
  ./toggle_terminal_theme_macos.sh          # Toggle
  ./toggle_terminal_theme_macos.sh dark     # Force Dark
  ./toggle_terminal_theme_macos.sh light    # Force Light
  ```
- **Effet**: Change le profil par défaut de Terminal.app

### `sync_terminal_with_system_theme_macos.sh`
- **Rôle**: Synchronise Terminal.app avec l'apparence système
- **Usage**: `./sync_terminal_with_system_theme_macos.sh`
- **Détecte**: Mode sombre/clair de macOS (via AppleInterfaceStyle)
- **Action**: Met à jour le profil Terminal.app en conséquence

### `install_auto_theme_switch_macos.sh`
- **Rôle**: Installe un LaunchAgent pour synchronisation auto
- **Usage**: `./install_auto_theme_switch_macos.sh` (une seule fois)
- **Crée**: `~/Library/LaunchAgents/com.bluloco.terminal.theme.plist`
- **Effet**: Terminal.app suit automatiquement le mode système
- **Désinstaller**:
  ```bash
  launchctl unload ~/Library/LaunchAgents/com.bluloco.terminal.theme.plist
  rm ~/Library/LaunchAgents/com.bluloco.terminal.theme.plist
  ```

## 📚 Documentation (.md)

### `README_THEMES.md`
- **Rôle**: Documentation générale multi-plateforme
- **Contenu**:
  - Palette de couleurs Bluloco (Dark et Light)
  - Synchronisation des thèmes sur Linux (NixOS)
  - Workflow de mise à jour des couleurs
  - Tests de validation
  - Dépannage
- **Audience**: Linux + macOS

### `MACOS_SETUP.md`
- **Rôle**: Guide complet spécifique à macOS
- **Contenu**:
  - Installation pas-à-pas
  - Configuration des thèmes par défaut
  - Méthodes de bascule (manuel, auto)
  - Synchronisation avec système
  - Personnalisation
  - Dépannage macOS
- **Audience**: Utilisateurs macOS uniquement

### `FILES_INDEX.md` (ce fichier)
- **Rôle**: Index de tous les fichiers avec leur rôle
- **Utilisation**: Référence rapide pour comprendre la structure

## 🔄 Workflow de maintenance

### Modifier les couleurs

1. **Éditer** les fichiers sources:
   ```bash
   vim bluloco-dark.conf
   vim bluloco-light.conf
   ```

2. **Régénérer** les thèmes macOS:
   ```bash
   python3 fix_nscolor_format.py
   ```

3. **Sur Linux** (NixOS):
   ```bash
   nixos-rebuild switch
   kitty @ load-config  # Si Kitty ouvert
   ```

4. **Sur macOS**:
   - Transférer les nouveaux `.terminal`
   - Double-cliquer pour réimporter

### Ajouter une nouvelle couleur ANSI

1. Ajouter dans `.conf`:
   ```conf
   color16      #ff5555
   ```

2. Modifier `fix_nscolor_format.py` (lignes 95-104):
   ```python
   ansi_mapping = {
       ...
       'color16': 'ANSI16Color',
   }
   ```

3. Régénérer les fichiers

## 🗂️ Organisation des fichiers

```
shell/
├── Sources (Linux)
│   ├── bluloco-dark.conf
│   └── bluloco-light.conf
│
├── Thèmes (macOS)
│   ├── Bluloco-Dark.terminal
│   └── Bluloco-Light.terminal
│
├── Outils
│   ├── fix_nscolor_format.py
│   ├── toggle_terminal_theme_macos.sh
│   ├── sync_terminal_with_system_theme_macos.sh
│   └── install_auto_theme_switch_macos.sh
│
└── Documentation
    ├── README_THEMES.md
    ├── MACOS_SETUP.md
    └── FILES_INDEX.md
```

## 🎯 Fichiers à ne JAMAIS supprimer

- `bluloco-dark.conf` et `bluloco-light.conf` - Sources de vérité
- `Bluloco-Dark.terminal` et `Bluloco-Light.terminal` - Thèmes fonctionnels
- `fix_nscolor_format.py` - Seul moyen de régénérer les .terminal

Les autres fichiers peuvent être retéléchargés depuis Git si nécessaire.

---

**Dernière mise à jour**: 2026-02-04
**Statut**: ✅ Nettoyage complet effectué
**Fichiers**: 10 essentiels (8 supprimés)
