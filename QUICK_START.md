# Quick Start - Mode K3S Agent (Worker Node)

> **Note** : Ce guide suppose que vous avez déjà un cluster K3S existant.
> Si vous voulez créer un nouveau cluster standalone, consultez la documentation dans `features/services/k3s.nix`.

## TL;DR - Démarrage ultra-rapide

### ⚠️ IMPORTANT : Configuration du cluster

Avant de builder, vous devez **configurer le cluster K3S à rejoindre** :

```bash
# 1. Éditer la config du cluster
vim hosts/sleeper/k3s-cluster-config.nix
# → Remplacez "192.168.1.100" par l'IP de votre serveur K3S

# 2. Obtenir le token du serveur K3S (sur le serveur)
ssh user@your-k3s-server
sudo cat /var/lib/rancher/k3s/server/node-token
# → Copiez le token

# 3. Créer le fichier token sur sleeper
echo "VOTRE_TOKEN_ICI" | sudo tee /var/lib/rancher/k3s/token
sudo chmod 600 /var/lib/rancher/k3s/token
```

**Voir [K3S_JOIN_CLUSTER.md](./K3S_JOIN_CLUSTER.md) pour les instructions détaillées.**

### Démarrage

```bash
# 1. Build la nouvelle configuration
sudo nixos-rebuild switch --flake .#sleeper

# 2. Reboot
sudo reboot

# 3. Au menu de boot, choisir "NixOS (k3s-server)"
#    Utiliser ↑/↓ pour sélectionner, puis Entrée

# 4. Vérifier que sleeper a rejoint le cluster
# Sur le serveur K3S :
kubectl get nodes
# Vous devriez voir "sleeper" dans la liste

# 5. Une fois en mode agent, déployer Ollama sur le cluster
cd /home/peuleu/nixos-config/examples/
./ollama-k8s-helper.sh deploy

# 6. Tester avec un modèle léger
./ollama-k8s-helper.sh quick-test
```

**Pour revenir au mode Desktop** : Redémarrer et choisir "NixOS" (sans suffixe)

---

## Qu'est-ce qui a changé ?

Votre machine `sleeper` peut maintenant démarrer en **deux modes différents** :

### 🖥️ **Mode Desktop** (par défaut)
- Interface graphique Hyprland
- GPU partagé entre desktop et applications
- Ollama disponible comme service systemd (usage local simple)
- Tous vos services habituels

### 🚀 **Mode K3S Agent**
- Headless (pas de GUI)
- GPU 100% dédié à K3S
- Rejoint un cluster K3S existant comme worker node
- K3S orchestre tous les workloads GPU (Ollama, autres LLM)
- Pas de service Ollama systemd (tout géré par K3S)
- Optimisé pour production et orchestration

> **Note** : Ce mode est configuré pour rejoindre un cluster existant.
> Si vous voulez un cluster standalone, voir `features/services/k3s.nix`

## Comment ça marche ?

Au boot, vous voyez un menu **systemd-boot** avec :

```
NixOS                    ← Mode Desktop
NixOS (k3s-server)      ← Mode Serveur
```

Sélectionnez le mode désiré avec ↑/↓ et appuyez sur **Entrée**.

## Méthodes de basculement

### Méthode 1 : Au boot (RECOMMANDÉ) ✨

```
Reboot → Menu systemd-boot → Choisir "NixOS (k3s-server)"
```

**Avantage** : Propre, sans risque, pas de commandes à taper

### Méthode 2 : Script helper

```bash
# Voir le statut actuel
./switch-mode.sh status

# Définir le mode par défaut pour le prochain boot
./switch-mode.sh boot-server    # Serveur par défaut
./switch-mode.sh boot-desktop   # Desktop par défaut

# Switcher immédiatement (sans reboot)
./switch-mode.sh server         # ⚠️ Tue la session graphique !
./switch-mode.sh desktop
```

### Méthode 3 : Commandes directes (avancé)

```bash
# Activer serveur au prochain boot
sudo /run/current-system/specialisation/k3s-server/bin/switch-to-configuration boot

# Activer desktop au prochain boot
sudo /run/current-system/bin/switch-to-configuration boot
```

## Une fois en mode Serveur

### Vérifier que tout fonctionne

```bash
# Vérifier les services
systemctl status k3s
systemctl status ollama

# Vérifier le GPU
nvidia-smi

# Vérifier K3S
sudo k3s kubectl get nodes
```

### Déployer Ollama sur K3S

```bash
cd /home/peuleu/nixos-config/examples/

# Déployer
./ollama-k8s-helper.sh deploy

# Télécharger un modèle
./ollama-k8s-helper.sh pull llama2

# Tester
./ollama-k8s-helper.sh run llama2 "Explain Kubernetes"
```

### Accès distant

```bash
# SSH
ssh peuleu@<ip-sleeper>

# Ollama API (depuis une autre machine)
curl http://<ip-sleeper>:31434/api/version

# K3S (copier le kubeconfig)
scp peuleu@<ip-sleeper>:/etc/rancher/k3s/k3s.yaml ~/.kube/sleeper.yaml
# Éditer et remplacer 127.0.0.1 par l'IP de sleeper
```

## Monitoring

```bash
# GPU
nvidia-smi           # Snapshot
nvtop               # Interface interactive

# K8S
kubectl get pods -A
k9s                 # TUI interactif

# Système
htop
btop

# Tout en un
./switch-mode.sh status
```

## Utilisation d'Ollama selon le mode

### En mode Desktop

Ollama tourne comme **service systemd** (simple et direct) :

```bash
# Utiliser Ollama directement
ollama pull llama2
ollama run llama2

# API sur localhost:11434
curl http://localhost:11434/api/version
```

### En mode K3S Server

Ollama est **géré par K3S** (orchestration complète) :

```bash
# Déployer Ollama sur K3S
cd examples/
./ollama-k8s-helper.sh deploy

# Utiliser via le helper
./ollama-k8s-helper.sh pull llama2
./ollama-k8s-helper.sh run llama2

# API via NodePort
curl http://<ip-sleeper>:31434/api/version
```

**Pourquoi cette différence ?**
- **Desktop** : Usage simple, interactif, local
- **Serveur** : K3S gère le GPU, permet scaling, monitoring, orchestration multi-services

## FAQ

### Q: Puis-je changer le mode par défaut ?
**R:** Oui, utilisez `./switch-mode.sh boot-server` ou `boot-desktop`

### Q: Faut-il rebuild à chaque changement ?
**R:** Non ! Une fois que vous avez fait `sudo nixos-rebuild switch` la première fois, les deux modes sont disponibles. Choisissez au boot.

### Q: Que se passe-t-il si j'oublie de choisir au boot ?
**R:** Le mode par défaut (Desktop) démarre automatiquement après quelques secondes.

### Q: Les données persistent entre les modes ?
**R:** Oui, c'est le même système de fichiers. Vos données sont préservées.

### Q: Puis-je utiliser Ollama en mode Desktop ?
**R:** Oui ! En mode Desktop, Ollama tourne comme service systemd simple. Le GPU est partagé avec votre environnement graphique.

### Q: Comment savoir dans quel mode je suis ?
**R:** `./switch-mode.sh status` ou regardez si Hyprland tourne

### Q: Les modèles Ollama sont-ils partagés entre les modes ?
**R:** Non, ils sont stockés séparément :
- **Mode Desktop** : `/var/lib/ollama/` (service systemd)
- **Mode K3S Server** : `/var/lib/ollama-k8s/` (K3S PersistentVolume)

**Avantage** : Isolation complète, pas de conflit.
**Inconvénient** : Il faut télécharger les modèles dans chaque mode.

### Q: Pourquoi ne pas avoir Ollama systemd en mode serveur aussi ?
**R:** Pour éviter les conflits GPU ! En mode serveur, K3S a 100% du GPU et orchestre tout (Ollama + potentiellement d'autres workloads). C'est plus propre et flexible.

## Ressources

- **Documentation complète** : [K3S_SERVER_MODE.md](./K3S_SERVER_MODE.md)
- **Exemples K8S** : [examples/README.md](./examples/README.md)
- **Script helper** : `./switch-mode.sh help`

## Besoin d'aide ?

```bash
# Vérifier la config
./switch-mode.sh status

# Voir les logs
journalctl -u k3s -f
journalctl -u ollama -f

# Vérifier K3S
sudo k3s kubectl get pods -A
sudo k3s kubectl get events --sort-by='.lastTimestamp'
```
