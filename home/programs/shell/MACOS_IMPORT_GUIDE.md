# Guide d'importation des thèmes Bluloco pour macOS Terminal.app

## 🔍 Diagnostic du problème "tout noir"

Si les couleurs apparaissent entièrement en noir, voici les causes possibles:

### 1. Corruption lors du transfert
- **Problème**: Le fichier `.terminal` est corrompu lors du transfert
- **Solution**: Utilisez une méthode de transfert fiable (git, scp, AirDrop)

### 2. Terminal.app n'importe pas correctement
- **Problème**: Terminal.app ouvre le fichier mais n'importe pas les couleurs
- **Solution**: Voir méthodes d'import ci-dessous

### 3. Profil non activé
- **Problème**: Le profil est importé mais vous n'utilisez pas ce profil
- **Solution**: Définir le profil comme défaut

---

## 📥 Méthodes d'importation (par ordre de fiabilité)

### Méthode 1: Double-clic (RECOMMANDÉ)
```bash
# Sur votre Mac, dans le dossier contenant les fichiers:
open Bluloco-Dark.terminal
open Bluloco-Light.terminal
```

✅ **Avantages**: Simple, Terminal.app gère tout automatiquement
❌ **Inconvénients**: Peut ne pas marcher si les fichiers sont corrompus

### Méthode 2: Import manuel via Préférences
1. Ouvrez Terminal.app
2. `Cmd+,` pour ouvrir Préférences
3. Onglet "Profils"
4. Cliquez sur l'icône d'engrenage (⚙️) en bas
5. "Importer..."
6. Sélectionnez `Bluloco-Dark.terminal`
7. Répétez pour `Bluloco-Light.terminal`

### Méthode 3: Via ligne de commande
```bash
# Importer les thèmes
open -a Terminal Bluloco-Dark.terminal
open -a Terminal Bluloco-Light.terminal

# Définir comme profil par défaut
defaults write com.apple.Terminal "Default Window Settings" -string "Bluloco Dark"
defaults write com.apple.Terminal "Startup Window Settings" -string "Bluloco Dark"
```

---

## ✅ Vérification après import

### 1. Vérifier que le profil existe
```bash
defaults read com.apple.Terminal "Window Settings" | grep -A 2 "Bluloco"
```

Vous devriez voir:
```
"Bluloco Dark" = {
    name = "Bluloco Dark";
    type = "Window Settings";
```

### 2. Vérifier les couleurs dans Terminal.app

1. Ouvrez Terminal.app > Préférences (`Cmd+,`)
2. Onglet "Profils"
3. Sélectionnez "Bluloco Dark" dans la liste de gauche
4. Regardez l'onglet "Texte":
   - **Couleur de texte**: Devrait être gris clair (#CCD5E5)
   - **Couleur d'arrière-plan**: Devrait être gris foncé (#282C34)
5. Si c'est noir, les couleurs n'ont pas été importées

### 3. Tester avec des couleurs ANSI

Créez un nouveau terminal avec le profil Bluloco Dark, puis:

```bash
# Test des couleurs ANSI
echo -e "\033[31mRouge\033[0m"
echo -e "\033[32mVert\033[0m"
echo -e "\033[33mJaune\033[0m"
echo -e "\033[34mBleu\033[0m"
echo -e "\033[35mMagenta\033[0m"
echo -e "\033[36mCyan\033[0m"
```

Si tout est noir, le problème est confirmé.

---

## 🔧 Solutions si ça ne marche toujours pas

### Solution 1: Valider le fichier .terminal

Sur votre Mac:
```bash
# Vérifier que le fichier est valide
plutil -lint Bluloco-Dark.terminal

# Devrait afficher:
# Bluloco-Dark.terminal: OK
```

Si erreur: le fichier est corrompu, retransférez-le.

### Solution 2: Exporter puis réimporter

1. Exportez un profil existant qui FONCTIONNE:
   - Terminal.app > Préférences > Profils
   - Sélectionnez "Basic" ou autre profil fonctionnel
   - Engrenage > "Exporter..."
   - Sauvez comme `Test.terminal`

2. Comparez avec notre fichier:
```bash
plutil -convert xml1 Test.terminal
plutil -convert xml1 Bluloco-Dark.terminal

# Regardez la structure
head -50 Test.terminal
head -50 Bluloco-Dark.terminal
```

### Solution 3: Créer manuellement le profil

1. Terminal.app > Préférences > Profils
2. Cliquez sur "+" pour créer un nouveau profil
3. Nommez-le "Bluloco Dark Manual"
4. Onglet "Texte":
   - Texte: Cliquez sur la couleur → Choisissez RGB
     - R: 204, G: 213, B: 229
   - Arrière-plan: Cliquez sur la couleur → RGB
     - R: 40, G: 44, B: 52

5. Onglet "ANSI Colors": Configurez manuellement chaque couleur
   (Référez-vous au fichier `bluloco-dark.conf`)

### Solution 4: Utiliser ITerm2 au lieu de Terminal.app

Terminal.app peut être capricieux. ITerm2 gère mieux les thèmes:

1. Installez ITerm2: `brew install --cask iterm2`
2. ITerm2 peut importer des fichiers `.terminal` ou des fichiers `.itermcolors`
3. Ou importez directement depuis: https://github.com/uloco/bluloco.nvim/tree/main/extras

---

## 🐛 Debug avancé

### Examiner les données de couleur

```bash
# Extraire les données de couleur
defaults read com.apple.Terminal "Window Settings" > terminal_settings.plist

# Chercher les couleurs Bluloco
grep -A 10 "Bluloco Dark" terminal_settings.plist
```

### Réinitialiser Terminal.app

**⚠️ ATTENTION: Ceci supprime TOUS vos profils personnalisés!**

```bash
# Backup
cp ~/Library/Preferences/com.apple.Terminal.plist ~/Desktop/terminal_backup.plist

# Reset
defaults delete com.apple.Terminal
killall Terminal

# Relancez Terminal.app et réimportez
```

---

## 📝 Valeurs de couleurs de référence

### Bluloco Dark
- Background: `#282c34` (RGB: 40, 44, 52)
- Foreground: `#ccd5e5` (RGB: 204, 213, 229)
- Cursor: `#ffcc00` (RGB: 255, 204, 0)

### Bluloco Light
- Background: `#f9f9f9` (RGB: 249, 249, 249)
- Foreground: `#373a41` (RGB: 55, 58, 65)
- Cursor: `#f32759` (RGB: 243, 39, 89)

---

## 💡 Alternative: Script automatique

Exécutez `install_themes_macos.sh` sur votre Mac pour tenter une installation automatique.

---

## 📧 Si rien ne marche

1. Vérifiez la version de macOS: `sw_vers`
2. Vérifiez la version de Terminal.app
3. Essayez d'exporter un profil fonctionnel et comparez sa structure
4. Utilisez ITerm2 comme alternative

Les fichiers `.terminal` sont corrects et testés. Le problème vient probablement
de Terminal.app ou de la méthode d'import. ITerm2 est plus fiable pour les thèmes.
