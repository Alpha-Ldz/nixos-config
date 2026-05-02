# 📝 Prévisualisation Markdown dans Neovim

## Plugins installés

### 1. **markdown-preview.nvim**
- Ouvre un aperçu HTML dans votre navigateur
- Synchronisation en temps réel
- Support des graphiques (mermaid, PlantUML, etc.)

### 2. **render-markdown.nvim**
- Rendu inline directement dans Neovim
- Affiche les titres avec des icônes
- Colore les blocs de code
- Affiche les checkboxes joliment

## ⌨️ Raccourcis clavier

| Raccourci | Action |
|-----------|--------|
| `<leader>mp` | **Markdown Preview** - Ouvre l'aperçu dans le navigateur |
| `<leader>ms` | **Markdown Stop** - Ferme l'aperçu |
| `<leader>mt` | **Markdown Toggle** - Bascule l'aperçu |

**Note**: `<leader>` est la touche **Espace** dans votre configuration.

## 🚀 Utilisation

### Aperçu dans le navigateur

1. Ouvrir un fichier Markdown:
   ```bash
   nvim README.md
   ```

2. Lancer l'aperçu:
   ```
   <Space>mp
   ```
   Ou en mode commande:
   ```vim
   :MarkdownPreview
   ```

3. Éditer le fichier - l'aperçu se met à jour automatiquement!

4. Fermer l'aperçu:
   ```
   <Space>ms
   ```

### Rendu inline dans Neovim

Le plugin `render-markdown` s'active automatiquement quand vous ouvrez un fichier `.md`:

- **Titres**: Affichés avec des icônes (󰲡, 󰲣, 󰲥, etc.)
- **Listes**: Puces jolies (●, ○, ◆, ◇)
- **Checkboxes**:
  - `[ ]` → 󰄱 (non coché)
  - `[x]` → 󰱒 (coché)
- **Code blocks**: Surligné avec votre colorscheme

## 🎨 Exemples

### Titres
```markdown
# Titre niveau 1    → 󰲡 Titre niveau 1
## Titre niveau 2   → 󰲣 Titre niveau 2
### Titre niveau 3  → 󰲥 Titre niveau 3
```

### Listes
```markdown
- Item 1           → ● Item 1
  - Sub-item       →   ○ Sub-item
    - Sub-sub      →     ◆ Sub-sub
```

### Checkboxes
```markdown
- [ ] Todo         → ● 󰄱 Todo
- [x] Fait         → ● 󰱒 Fait
```

### Code blocks
```markdown
\`\`\`python
def hello():
    print("Hello World")
\`\`\`
```

Sera coloré selon le thème Bluloco!

## ⚙️ Configuration

### Changer le navigateur

Éditez `markdown.nix`:
```nix
browser = "firefox";  # ou "chrome", "safari", etc.
```

### Désactiver le rendu inline

Si vous préférez voir le Markdown brut:
```nix
plugins.render-markdown = {
  enable = false;
};
```

### Auto-démarrer l'aperçu

Pour ouvrir automatiquement l'aperçu quand vous ouvrez un `.md`:
```nix
auto_start = true;
```

## 🐛 Dépannage

### L'aperçu ne s'ouvre pas

```bash
# Vérifier que Node.js est installé
node --version

# Rebuild la config
sudo nixos-rebuild switch
```

### Port déjà utilisé

Si le port 8080 est occupé, changez-le dans `markdown.nix`:
```nix
port = "8081";
```

### Le rendu inline ne marche pas

```vim
" Dans Neovim, vérifier que le plugin est chargé
:Lazy

" Recharger le plugin
:Lazy reload render-markdown.nvim
```

## 📚 Commandes disponibles

### markdown-preview.nvim

```vim
:MarkdownPreview        " Ouvrir l'aperçu
:MarkdownPreviewStop    " Fermer l'aperçu
:MarkdownPreviewToggle  " Basculer l'aperçu
```

### render-markdown.nvim

```vim
:RenderMarkdown enable   " Activer le rendu
:RenderMarkdown disable  " Désactiver le rendu
:RenderMarkdown toggle   " Basculer le rendu
```

## 💡 Astuces

### Édition en split

```vim
" Ouvrir en split vertical
:vsplit README.md
<Space>mp

" Éditer à gauche, aperçu à droite
```

### Exporter en HTML

L'aperçu génère un HTML que vous pouvez sauvegarder:
```vim
:MarkdownPreview
" Dans le navigateur: Fichier > Enregistrer sous...
```

### Synchronisation scroll

L'aperçu suit automatiquement votre position dans le fichier!

## 🔗 Ressources

- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
- [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)
- [Markdown Guide](https://www.markdownguide.org/)

---

**Installation**: Automatique après `sudo nixos-rebuild switch`
**Démarrage**: Ouvrir n'importe quel fichier `.md`
