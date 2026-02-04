# 🍎 Configuration Bluloco pour macOS Terminal.app

Guide complet pour installer et configurer les thèmes Bluloco sur macOS.

## 📥 Installation

### Étape 1: Transférer les fichiers

Copiez ces fichiers sur votre Mac:
- `Bluloco-Dark.terminal`
- `Bluloco-Light.terminal`
- `toggle_terminal_theme_macos.sh`
- `sync_terminal_with_system_theme_macos.sh`
- `install_auto_theme_switch_macos.sh`

### Étape 2: Importer les thèmes

**Méthode A - Double-clic (recommandé)**:
```bash
open Bluloco-Dark.terminal
open Bluloco-Light.terminal
```

**Méthode B - Import manuel**:
1. Terminal.app > Préférences (`Cmd+,`)
2. Onglet **Profils**
3. Icône d'engrenage (⚙️) > **Importer...**
4. Sélectionnez les fichiers `.terminal`

### Étape 3: Définir le thème par défaut

**Via l'interface**:
1. Terminal.app > Préférences > Profils
2. Sélectionnez **Bluloco Dark** (ou Light)
3. Cliquez sur **"Par défaut"** en bas

**Via la ligne de commande**:
```bash
# Dark theme
defaults write com.apple.Terminal "Default Window Settings" -string "Bluloco Dark"
defaults write com.apple.Terminal "Startup Window Settings" -string "Bluloco Dark"

# Light theme
defaults write com.apple.Terminal "Default Window Settings" -string "Bluloco Light"
defaults write com.apple.Terminal "Startup Window Settings" -string "Bluloco Light"
```

## 🔄 Basculer entre les thèmes

### Option 1: Manuel via Interface

**Nouvelle fenêtre avec un thème**:
- Shell > Nouveau avec profil > Bluloco Dark/Light

**Changer le thème d'une fenêtre existante**:
- Clic droit sur l'onglet > Changer de profil

### Option 2: Script de bascule

```bash
# Rendre le script exécutable
chmod +x toggle_terminal_theme_macos.sh

# Basculer automatiquement
./toggle_terminal_theme_macos.sh

# Forcer Dark
./toggle_terminal_theme_macos.sh dark

# Forcer Light
./toggle_terminal_theme_macos.sh light
```

### Option 3: Raccourci clavier

Ajoutez un raccourci dans macOS:
1. **Réglages Système** > **Clavier** > **Raccourcis clavier**
2. **Services** > Ajouter un nouveau service
3. Associez-le au script `toggle_terminal_theme_macos.sh`

## 🌓 Synchronisation automatique avec le système

### Installation de la synchronisation auto

```bash
# Rendre les scripts exécutables
chmod +x *.sh

# Installer le LaunchAgent
./install_auto_theme_switch_macos.sh
```

Le thème Terminal.app se synchronisera automatiquement quand vous:
- Changez l'apparence système (Réglages > Apparence)
- Basculez entre mode Clair/Sombre

### Synchronisation manuelle

```bash
# Synchroniser maintenant
./sync_terminal_with_system_theme_macos.sh
```

### Vérifier les logs

```bash
# Voir les logs de synchronisation
tail -f /tmp/terminal-theme-sync.log
```

### Désactiver la synchronisation auto

```bash
launchctl unload ~/Library/LaunchAgents/com.bluloco.terminal.theme.plist
rm ~/Library/LaunchAgents/com.bluloco.terminal.theme.plist
```

## 🎨 Palette de couleurs

### Bluloco Dark
- **Background**: `#282c34` (Gris foncé)
- **Foreground**: `#ccd5e5` (Gris clair)
- **Cursor**: `#ffcc00` (Jaune/Or)

### Bluloco Light
- **Background**: `#f9f9f9` (Blanc cassé)
- **Foreground**: `#373a41` (Gris foncé)
- **Cursor**: `#f32759` (Rose)

## 🔧 Personnalisation

### Modifier les couleurs

Les couleurs sont définies dans:
- `bluloco-dark.conf`
- `bluloco-light.conf`

Après modification, régénérez les fichiers `.terminal`:
```bash
python3 fix_nscolor_format.py
```

Puis réimportez les nouveaux fichiers dans Terminal.app.

### Changer la police

1. Terminal.app > Préférences > Profils
2. Sélectionnez votre profil Bluloco
3. Onglet **Texte**
4. Cliquez sur **Police** et choisissez votre police

Ou modifiez directement le script `fix_nscolor_format.py` ligne 131:
```python
'Font': create_font_data("MaPolice-Regular", 14.0),
```

## 🐛 Dépannage

### Le background est noir au lieu de gris

✅ **Résolu!** Les nouveaux fichiers utilisent le format `NSColorSpace: 2` (Device RGB).

Si le problème persiste:
1. Supprimez les anciens profils Bluloco
2. Réimportez les nouveaux fichiers
3. Redémarrez Terminal.app

### Les couleurs ne changent pas

```bash
# Vérifier que les profils sont importés
defaults read com.apple.Terminal "Window Settings" | grep Bluloco

# Vérifier le profil par défaut
defaults read com.apple.Terminal "Default Window Settings"
```

### La synchronisation auto ne marche pas

```bash
# Vérifier que le LaunchAgent est chargé
launchctl list | grep bluloco

# Vérifier les logs
cat /tmp/terminal-theme-sync.log
cat /tmp/terminal-theme-sync.error.log

# Recharger le service
launchctl unload ~/Library/LaunchAgents/com.bluloco.terminal.theme.plist
launchctl load ~/Library/LaunchAgents/com.bluloco.terminal.theme.plist
```

## 📚 Comparaison avec Linux (NixOS)

### Linux
- ✅ Synchronisation automatique via `darkman`
- ✅ Recharge automatique de Kitty
- ✅ Switch automatique de Waybar, Firefox, Wallpaper

### macOS
- ⚠️ Synchronisation nécessite LaunchAgent
- ⚠️ Les fenêtres existantes ne changent pas
- ⚠️ Nécessite d'ouvrir de nouvelles fenêtres/onglets

### Workflow recommandé sur macOS

**Si vous utilisez les deux OS**:

1. **Sur Linux**: Le thème change automatiquement partout
2. **Sur macOS**:
   - Installez la synchronisation auto pour suivre le système
   - Ou utilisez `toggle_terminal_theme_macos.sh` manuellement

## 💡 Astuces

### Créer un alias

Ajoutez à votre `~/.zshrc` ou `~/.bashrc`:
```bash
# Raccourci pour changer de thème
alias theme-dark='~/path/to/toggle_terminal_theme_macos.sh dark'
alias theme-light='~/path/to/toggle_terminal_theme_macos.sh light'
alias theme-toggle='~/path/to/toggle_terminal_theme_macos.sh'
```

### Intégration avec BitBar/SwiftBar

Créez un plugin pour afficher le thème actuel dans la barre de menu:
```bash
#!/bin/bash
# bluloco-theme.1m.sh
THEME=$(defaults read com.apple.Terminal "Default Window Settings" 2>/dev/null)
if [[ "$THEME" == "Bluloco Dark" ]]; then
    echo "🌙"
else
    echo "☀️"
fi
```

## 🔗 Ressources

- [Bluloco Official](https://github.com/uloco/bluloco.nvim)
- [macOS LaunchAgent Documentation](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)
- [Terminal.app Preferences](https://ss64.com/osx/terminal.html)

---

**Dernière mise à jour**: 2026-02-04
**Statut**: ✅ Thèmes fonctionnels avec background correct
