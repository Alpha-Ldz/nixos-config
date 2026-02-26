# Notes de Session - Configuration K3S Agent pour sleeper

**Date:** 2026-02-24
**Machine:** sleeper
**Objectif:** Configurer sleeper comme worker node GPU dans un cluster K3S existant

---

## 📋 Contexte du Projet

### Besoin initial
- Faire tourner des LLM (Large Language Models) avec performance GPU maximale
- Utiliser Kubernetes (K3S) pour orchestrer les workloads
- Avoir un mode "serveur" sans interface graphique avec GPU 100% dédié
- Pouvoir basculer facilement entre mode Desktop et mode Serveur

### Architecture choisie

**Mode Desktop:**
- Interface Hyprland
- GPU partagé (desktop + applications)
- Ollama en service systemd (usage local simple)

**Mode K3S Agent:**
- Headless (pas de GUI)
- GPU 100% dédié à K3S
- Rejoint cluster K3S existant comme worker node
- Ollama géré par K3S (orchestration complète)

---

## 🛠️ Ce qui a été fait

### 1. Modules créés

#### Services
- **`features/services/k3s.nix`** - K3S en mode server (standalone)
- **`features/services/k3s-agent.nix`** - K3S en mode agent (rejoint cluster)
- **`features/services/ollama.nix`** - Ollama systemd (mode desktop)
- **`features/services/ollama-server.nix`** - Ollama optimisé (non utilisé finalement)

#### Hardware
- **`features/hardware/nvidia-headless.nix`** - Drivers NVIDIA sans X/Wayland
  - Configure videoDrivers pour nvidia-container-toolkit
  - GPU 100% dédié au compute
  - Persistence daemon activé

#### Profiles
- **`profiles/k3s-server.nix`** - Profile headless pour mode serveur
  - Pas d'interface graphique
  - Optimisations kernel pour K8S
  - Docker sans GUI
  - Auto-login TTY

### 2. Configuration sleeper

#### `hosts/sleeper/default.nix`
- **Mode par défaut:** Desktop (Hyprland + Ollama systemd)
- **Specialisation k3s-server:** Agent K3S headless

#### `hosts/sleeper/k3s-cluster-config.nix`
- **Server URL:** `https://192.168.1.17:6443`
- **Token file:** `/var/lib/rancher/k3s/token`

#### Token configuré
```bash
# Token stocké dans:
/var/lib/rancher/k3s/token

# Valeur:
K100c8b10cb9066511ca958c29902cc4b709d57dca401919b3846d5742df5e359fe::server:7fd34628ac1c996adfd8325b53302e58

# Permissions: 600, root:root
```

### 3. Scripts et helpers

- **`switch-mode.sh`** - Basculer entre modes (boot-server, boot-desktop, status)
- **`examples/ollama-k8s-helper.sh`** - Gérer Ollama sur K3S
- **`examples/ollama-k8s-deployment.yaml`** - Manifeste K8S pour Ollama

### 4. Documentation

- **`K3S_JOIN_CLUSTER.md`** - Guide complet pour rejoindre un cluster
- **`SETUP_CHECKLIST.md`** - Checklist étape par étape
- **`QUICK_START.md`** - Démarrage rapide
- **`K3S_SERVER_MODE.md`** - Documentation mode serveur
- **`ARCHITECTURE.md`** - Architecture Desktop vs K3S
- **`examples/README.md`** - Exemples Ollama sur K3S

### 5. Corrections effectuées

**Build errors corrigés:**
1. ✅ Retiré `sound.enable` de k3s-server.nix (déprécié)
2. ✅ Ajouté `services.xserver.videoDrivers = ["nvidia"]` dans nvidia-headless.nix
3. ✅ Retiré `enableNvidia` de Docker (problème 32-bit)

**Runtime errors corrigés:**
4. ✅ **[2026-02-24]** Retiré `--kubelet-arg=feature-gates=DevicePlugins=true` de k3s-agent.nix
   - **Problème:** Service k3s en crash loop avec erreur `unrecognized feature gate: DevicePlugins`
   - **Cause:** Feature gate `DevicePlugins` graduée en stable dans K8S 1.26 et supprimée dans versions ultérieures
   - **Solution:** Retirée de extraFlags - les device plugins (GPU) sont maintenant activés par défaut
   - **Fichier:** `features/services/k3s-agent.nix:39`
   - **Impact:** Le support GPU fonctionne nativement sans flag explicite en K3S v1.34.2

5. ✅ **[2026-02-24]** kubectl ne fonctionne pas sur sleeper (agent mode)
   - **Problème:** `kubectl get nodes` échoue avec "connection to server localhost:8080 was refused"
   - **Cause:** En mode agent, il n'y a pas d'API server local. Les agents se connectent uniquement au master distant
   - **Solution:** Copier le kubeconfig depuis le master (192.168.1.17) vers sleeper
   - **Impact:** kubectl nécessite la configuration du cluster master pour fonctionner sur un agent

---

## ⚙️ Configuration Actuelle

### Cluster K3S
- **Serveur:** 192.168.1.17:6443
- **Token:** Configuré dans `/var/lib/rancher/k3s/token`
- **sleeper:** Prêt à rejoindre comme agent

### Build Status
✅ Configuration compilée avec succès
```bash
sudo nixos-rebuild switch --flake .#sleeper
```

### Boot Options
- `NixOS` → Mode Desktop
- `NixOS (k3s-server)` → Mode K3S Agent

---

## 🎯 État Actuel

### ✅ Complété
- [x] Configuration K3S agent créée
- [x] Token et URL cluster configurés
- [x] Build réussi
- [x] Documentation complète
- [x] Scripts helpers créés
- [x] K3S agent démarré et fonctionnel
- [x] sleeper a rejoint le cluster avec succès
- [x] Pods du cluster s'exécutent sur sleeper (metallb, longhorn)

### ⏳ En attente (Prochaines étapes)
- [ ] **Configurer kubectl sur sleeper (copier kubeconfig depuis master)**
- [ ] Vérifier status du node sleeper avec kubectl
- [ ] Installer NVIDIA Device Plugin (si pas déjà fait sur le cluster)
- [ ] Vérifier détection GPU
- [ ] Déployer Ollama sur le cluster
- [ ] Tester avec un modèle

---

## 🚀 Prochaines Étapes (À FAIRE)

### 1. Configurer kubectl (IMPORTANT - À FAIRE APRÈS REBOOT)

**Pourquoi:** En mode agent, il n'y a pas d'API server local. kubectl doit se connecter au master.

**Commande à exécuter sur sleeper après reboot:**
```bash
# Créer le répertoire .kube
mkdir -p ~/.kube

# Récupérer le kubeconfig depuis le master (mot de passe requis)
ssh peuleu_server@192.168.1.17 "sudo cat /etc/rancher/k3s/k3s.yaml" | sed 's/127.0.0.1/192.168.1.17/g' > ~/.kube/config

# Sécuriser les permissions
chmod 600 ~/.kube/config

# Tester
kubectl get nodes
```

**Note:** Le SSH utilise l'utilisateur `peuleu_server` avec authentification par mot de passe.

### 2. Redémarrer en mode K3S Agent (OPTIONNEL si pas déjà fait)

```bash
sudo reboot
# Au menu de boot: choisir "NixOS (k3s-server)"
```

### 3. Vérifier que sleeper a rejoint le cluster

**Sur sleeper:**
```bash
systemctl status k3s
journalctl -u k3s -f  # Chercher "Successfully registered"
```

**Depuis n'importe où avec kubectl configuré:**
```bash
kubectl get nodes
# Devrait afficher "sleeper" dans la liste avec status "Ready"
```

### 4. Installer NVIDIA Device Plugin

**Une seule fois sur le cluster:**
```bash
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml
```

### 5. Vérifier GPU

```bash
# Vérifier capacité GPU
kubectl get node sleeper -o json | jq '.status.capacity."nvidia.com/gpu"'
# Devrait retourner "1"

# Test GPU
kubectl run gpu-test --rm -ti --restart=Never \
  --image=nvidia/cuda:12.0.0-base-ubuntu22.04 \
  --limits=nvidia.com/gpu=1 \
  --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"sleeper"}}}' \
  -- nvidia-smi
```

### 6. Déployer Ollama

```bash
cd /home/peuleu/nixos-config/examples/
./ollama-k8s-helper.sh deploy
./ollama-k8s-helper.sh pull tinyllama
./ollama-k8s-helper.sh run tinyllama "Hello world"
```

---

## 📊 Architecture Finale

```
┌─────────────────────────────────────┐
│   Cluster K3S                       │
│                                     │
│   Master (192.168.1.17:6443)        │
│   ├─ Control Plane                  │
│   ├─ etcd                           │
│   └─ API Server                     │
│                                     │
│   Worker: sleeper                   │
│   ├─ GPU: 100% dédié à K3S          │
│   ├─ Labels: gpu=nvidia             │
│   ├─ Labels: workload=llm           │
│   └─ Workloads:                     │
│       └─ Ollama Pod (GPU)           │
└─────────────────────────────────────┘
```

---

## 🔧 Commandes Utiles

### Basculer entre modes

```bash
# Voir le statut actuel
./switch-mode.sh status

# Définir le mode par défaut pour le prochain boot
./switch-mode.sh boot-server   # K3S Agent
./switch-mode.sh boot-desktop  # Desktop

# Switcher immédiatement (sans reboot)
./switch-mode.sh server   # ⚠️ Tue la session graphique
./switch-mode.sh desktop
```

### Gérer le cluster

```bash
# Lister les nodes
kubectl get nodes

# Détails du node sleeper
kubectl describe node sleeper

# Pods sur sleeper
kubectl get pods --all-namespaces --field-selector spec.nodeName=sleeper

# GPU disponible
kubectl describe node sleeper | grep -A 5 "Capacity"
```

### Gérer Ollama sur K3S

```bash
cd /home/peuleu/nixos-config/examples/

# Déployer
./ollama-k8s-helper.sh deploy

# Status
./ollama-k8s-helper.sh status

# Lister modèles
./ollama-k8s-helper.sh list

# Pull un modèle
./ollama-k8s-helper.sh pull llama2

# Run un modèle
./ollama-k8s-helper.sh run llama2 "Explain Kubernetes"

# Logs
./ollama-k8s-helper.sh logs

# Test GPU
./ollama-k8s-helper.sh test-gpu
```

### Monitoring

```bash
# GPU (sur sleeper)
nvidia-smi
nvtop

# Services (sur sleeper)
systemctl status k3s
journalctl -u k3s -f

# Cluster (depuis n'importe où avec kubectl)
kubectl top nodes
kubectl top pods -A
kubectl get events --sort-by='.lastTimestamp'
k9s  # TUI interactif
```

---

## 🐛 Troubleshooting

### ❌ kubectl: "connection to server localhost:8080 was refused" (RÉSOLU)

**Symptômes:**
```bash
kubectl get nodes
# E0224 22:01:40.097394 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connect: connection refused"
# The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

**Cause:**
- En mode **k3s-agent**, il n'y a **PAS** d'API server local
- Les agents se connectent uniquement au master distant (192.168.1.17:6443)
- kubectl cherche par défaut un serveur local sur le port 8080

**Solution:**
```bash
# Récupérer le kubeconfig depuis le master
mkdir -p ~/.kube
ssh peuleu_server@192.168.1.17 "sudo cat /etc/rancher/k3s/k3s.yaml" | sed 's/127.0.0.1/192.168.1.17/g' > ~/.kube/config
chmod 600 ~/.kube/config
```

**Vérification:**
```bash
kubectl get nodes  # Devrait maintenant fonctionner
kubectl cluster-info  # Devrait montrer le master à 192.168.1.17:6443
```

**Note importante:** En mode agent, le service k3s peut être parfaitement fonctionnel (pods en cours d'exécution) même si kubectl ne fonctionne pas. Ce sont deux choses distinctes.

### ❌ K3S en crash loop - "unrecognized feature gate: DevicePlugins" (RÉSOLU)

**Symptômes:**
```bash
systemctl status k3s  # Restart counter élevé
journalctl -u k3s -n 50 | grep "unrecognized feature gate: DevicePlugins"
# Error: failed to set feature gates from initial flags-based config: unrecognized feature gate: DevicePlugins
```

**Cause:**
- Feature gate `DevicePlugins` obsolète dans K8S 1.34+
- Les device plugins sont maintenant toujours activés par défaut

**Solution:**
1. Éditer `features/services/k3s-agent.nix`
2. Retirer la ligne `"--kubectl-arg=feature-gates=DevicePlugins=true"`
3. Rebuild: `sudo nixos-rebuild switch --flake .#sleeper`
4. Restart: `sudo systemctl restart k3s`

**Vérification:**
```bash
systemctl status k3s  # Devrait être "active (running)" stable
journalctl -u k3s -f  # Chercher "Successfully registered"
```

### sleeper n'apparaît pas dans kubectl get nodes

**Sur sleeper:**
```bash
systemctl status k3s
journalctl -u k3s -f
# Vérifier le token
sudo cat /var/lib/rancher/k3s/token
# Vérifier la connectivité
ping 192.168.1.17
curl -k https://192.168.1.17:6443
```

### GPU non détecté

```bash
# Vérifier nvidia-smi
nvidia-smi

# Vérifier device plugin
kubectl get pods -n kube-system | grep nvidia
kubectl logs -n kube-system <nvidia-device-plugin-pod>

# Vérifier les labels du node
kubectl get node sleeper --show-labels
```

### Ollama ne démarre pas

```bash
# Events du pod
kubectl describe pod -n llm -l app=ollama

# Logs
kubectl logs -n llm -l app=ollama -f

# Vérifier qu'il est planifié sur sleeper
kubectl get pod -n llm -o wide
```

---

## 📁 Fichiers Importants

### Configuration
```
nixos-config/
├── features/
│   ├── hardware/nvidia-headless.nix       # Drivers GPU headless
│   └── services/
│       ├── k3s-agent.nix                  # K3S agent mode
│       └── ollama-server.nix              # Ollama optimisé
├── profiles/
│   └── k3s-server.nix                     # Profile headless
├── hosts/sleeper/
│   ├── default.nix                        # Config avec specialisation
│   └── k3s-cluster-config.nix             # URL et token cluster
└── examples/
    ├── ollama-k8s-deployment.yaml         # Manifeste Ollama
    └── ollama-k8s-helper.sh               # Helper script
```

### Documentation
```
├── K3S_JOIN_CLUSTER.md      # Guide complet
├── SETUP_CHECKLIST.md       # Checklist étape par étape
├── QUICK_START.md           # Démarrage rapide
├── ARCHITECTURE.md          # Architecture détaillée
└── SESSION_NOTES.md         # Ce fichier (contexte)
```

---

## 💡 Notes Importantes

### Isolation GPU
- **Mode Desktop:** GPU partagé avec Hyprland
- **Mode K3S Agent:** GPU 100% dédié à K3S (aucun service systemd Ollama)

### Stockage Ollama
- **Mode Desktop:** `/var/lib/ollama/` (service systemd)
- **Mode K3S:** `/var/lib/ollama-k8s/` (PersistentVolume K8S)
- Les modèles ne sont PAS partagés entre les modes

### Node Labels
Le node sleeper a les labels suivants (définis dans k3s-agent.nix):
- `gpu=nvidia`
- `gpu-type=dedicated`
- `workload=llm`

Utile pour le scheduling :
```yaml
nodeSelector:
  gpu: nvidia
  workload: llm
```

### Accès Ollama

**Mode Desktop:**
```bash
ollama run llama2
curl http://localhost:11434/api/version
```

**Mode K3S Agent:**
```bash
# Via helper
./ollama-k8s-helper.sh run llama2

# Via API (NodePort)
curl http://<node-ip>:31434/api/version
```

---

## 🔄 Retour en arrière

### Revenir au mode Desktop
Simplement redémarrer et choisir "NixOS" (sans suffixe) au boot.

### Passer en mode standalone K3S
Si vous voulez un cluster K3S standalone au lieu de rejoindre un cluster:

1. Éditer `hosts/sleeper/default.nix`
2. Dans la specialisation, remplacer:
   ```nix
   ../../features/services/k3s-agent.nix
   ```
   par:
   ```nix
   ../../features/services/k3s.nix
   ```
3. Retirer:
   ```nix
   ./k3s-cluster-config.nix
   ```
4. Rebuild: `sudo nixos-rebuild switch --flake .#sleeper`

---

## 📞 Support

- **Documentation:** Voir les fichiers MD dans `/home/peuleu/nixos-config/`
- **Checklist:** `SETUP_CHECKLIST.md` pour suivi pas à pas
- **Troubleshooting:** `K3S_JOIN_CLUSTER.md` section Troubleshooting

---

## ✅ Checklist État Actuel

- [x] Configuration créée et validée
- [x] Build réussi
- [x] Token cluster configuré
- [x] Documentation complète
- [x] Problème crash loop K3S diagnostiqué et corrigé
- [x] K3S agent fonctionne et exécute des pods du cluster
- [x] Diagnostic kubectl effectué (erreur localhost:8080 identifiée)
- [ ] **→ PROCHAINE ÉTAPE: Configurer kubectl avec kubeconfig du master**

---

**Dernière mise à jour:** [2026-02-24 22:03] K3S agent fonctionne - kubectl nécessite configuration
**Commande suivante après reboot:**
```bash
mkdir -p ~/.kube
ssh peuleu_server@192.168.1.17 "sudo cat /etc/rancher/k3s/k3s.yaml" | sed 's/127.0.0.1/192.168.1.17/g' > ~/.kube/config
chmod 600 ~/.kube/config
kubectl get nodes
```
