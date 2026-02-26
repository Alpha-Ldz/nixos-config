# Setup Checklist - sleeper comme K3S Agent Node

Guide étape par étape pour configurer sleeper comme worker node GPU dans un cluster K3S existant.

## ✅ Checklist complète

### 📋 Phase 1 : Préparation (AVANT le build)

- [ ] **1.1** Vous avez un cluster K3S qui tourne déjà
- [ ] **1.2** Vous connaissez l'IP/hostname du serveur K3S master
- [ ] **1.3** Vous avez un accès SSH au serveur K3S

### 🔑 Phase 2 : Récupérer le token

Sur le **serveur K3S** (pas sur sleeper) :

```bash
# Se connecter au serveur
ssh user@your-k3s-server

# Récupérer le token
sudo cat /var/lib/rancher/k3s/server/node-token
```

- [ ] **2.1** Token copié (ressemble à `K10abc...::server:123...`)

### ⚙️ Phase 3 : Configurer sleeper

Sur **sleeper** (ou via SSH) :

#### 3.1 Éditer la configuration du cluster

```bash
cd /home/peuleu/nixos-config/
vim hosts/sleeper/k3s-cluster-config.nix
```

Modifier :
```nix
serverUrl = "https://192.168.1.100:6443";  # Remplacer par votre IP !
```

- [ ] **3.1** IP du serveur K3S configurée dans `k3s-cluster-config.nix`

#### 3.2 Créer le fichier token

```bash
# Créer le répertoire
sudo mkdir -p /var/lib/rancher/k3s

# Créer le fichier token (remplacer par votre token)
echo "K10abc123def456...::server:123..." | sudo tee /var/lib/rancher/k3s/token

# Sécuriser
sudo chmod 600 /var/lib/rancher/k3s/token
sudo chown root:root /var/lib/rancher/k3s/token
```

- [ ] **3.2** Fichier token créé dans `/var/lib/rancher/k3s/token`
- [ ] **3.3** Permissions correctes (600, root:root)

### 🔨 Phase 4 : Build et activation

```bash
cd /home/peuleu/nixos-config/

# Build la configuration
sudo nixos-rebuild switch --flake .#sleeper
```

- [ ] **4.1** Build réussi sans erreurs
- [ ] **4.2** Deux entrées dans le bootloader (NixOS + NixOS (k3s-server))

### 🚀 Phase 5 : Premier démarrage en mode Agent

```bash
# Reboot
sudo reboot

# Au menu de boot : choisir "NixOS (k3s-server)"
```

- [ ] **5.1** Démarrage en mode K3S Agent
- [ ] **5.2** Auto-login en TTY

### ✓ Phase 6 : Vérification

Sur **sleeper** (via SSH si nécessaire) :

```bash
# Vérifier que K3S agent tourne
systemctl status k3s

# Voir les logs
journalctl -u k3s -f
```

Vous devriez voir dans les logs :
```
Successfully registered node with master
```

- [ ] **6.1** Service K3S actif
- [ ] **6.2** Logs montrent "Successfully registered"

Sur le **serveur K3S** :

```bash
# Lister les nodes
kubectl get nodes

# Voir les détails de sleeper
kubectl describe node sleeper
```

- [ ] **6.3** Node `sleeper` visible dans `kubectl get nodes`
- [ ] **6.4** Status = `Ready`

### 🎮 Phase 7 : Vérification GPU

```bash
# Sur sleeper
nvidia-smi

# Sur le serveur K3S (ou n'importe où avec kubectl)
kubectl get node sleeper -o json | jq '.status.capacity."nvidia.com/gpu"'
```

- [ ] **7.1** `nvidia-smi` fonctionne sur sleeper
- [ ] **7.2** GPU visible dans kubectl (`"nvidia.com/gpu": "1"`)

### 🔌 Phase 8 : Installer NVIDIA Device Plugin (si pas déjà fait)

```bash
# Sur n'importe quelle machine avec kubectl
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml

# Vérifier
kubectl get pods -n kube-system | grep nvidia
```

- [ ] **8.1** Device plugin déployé
- [ ] **8.2** Pod nvidia-device-plugin en état `Running`

### 🧪 Phase 9 : Test GPU

```bash
# Créer un pod de test
kubectl run gpu-test --rm -ti --restart=Never \
  --image=nvidia/cuda:12.0.0-base-ubuntu22.04 \
  --limits=nvidia.com/gpu=1 \
  --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"sleeper"}}}' \
  -- nvidia-smi
```

- [ ] **9.1** Pod exécuté avec succès
- [ ] **9.2** Sortie de `nvidia-smi` visible

### 🤖 Phase 10 : Déployer Ollama

```bash
cd /home/peuleu/nixos-config/examples/

# Déployer Ollama
./ollama-k8s-helper.sh deploy

# Vérifier
kubectl get pods -n llm
```

- [ ] **10.1** Ollama déployé
- [ ] **10.2** Pod Ollama en état `Running`
- [ ] **10.3** Pod Ollama planifié sur node `sleeper`

### 🎯 Phase 11 : Test final

```bash
# Télécharger un modèle
./ollama-k8s-helper.sh pull tinyllama

# Tester
./ollama-k8s-helper.sh run tinyllama "Hello world"
```

- [ ] **11.1** Modèle téléchargé avec succès
- [ ] **11.2** Réponse générée correctement

## 🎉 Configuration terminée !

Si toutes les cases sont cochées, votre configuration est complète et fonctionnelle !

## 🔧 En cas de problème

### Le node n'apparaît pas

```bash
# Sur sleeper - vérifier les logs
journalctl -u k3s -f

# Vérifier la connectivité
ping <ip-serveur-k3s>
curl -k https://<ip-serveur-k3s>:6443
```

**Causes courantes :**
- Token invalide ou expiré
- IP serveur incorrecte dans `k3s-cluster-config.nix`
- Firewall bloque le port 6443
- Réseau entre sleeper et le serveur

### Le GPU n'est pas détecté

```bash
# Vérifier nvidia-smi fonctionne
nvidia-smi

# Vérifier les logs K3S
journalctl -u k3s | grep -i nvidia

# Vérifier le device plugin
kubectl get pods -n kube-system | grep nvidia
kubectl logs -n kube-system <nvidia-device-plugin-pod>
```

### Ollama ne démarre pas

```bash
# Voir les events du pod
kubectl describe pod -n llm -l app=ollama

# Voir les logs
kubectl logs -n llm -l app=ollama
```

## 📚 Documentation

- **[K3S_JOIN_CLUSTER.md](./K3S_JOIN_CLUSTER.md)** - Guide détaillé pour rejoindre un cluster
- **[QUICK_START.md](./QUICK_START.md)** - Guide de démarrage rapide
- **[examples/README.md](./examples/README.md)** - Utilisation d'Ollama sur K3S

## 🔄 Retour au mode Desktop

Simple reboot et choisir "NixOS" (sans suffixe) au menu de boot.

---

**Besoin d'aide ?** Consultez [K3S_JOIN_CLUSTER.md](./K3S_JOIN_CLUSTER.md) section Troubleshooting.
