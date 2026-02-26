# Mode Serveur K3S avec GPU dédié

Cette configuration transforme votre machine en serveur headless optimisé pour faire tourner des LLM via Kubernetes (k3s) avec 100% du GPU dédié aux workloads.

## Architecture

### Allocation GPU par mode

| Mode | GPU utilisé par | Ollama géré par | Use case |
|------|-----------------|-----------------|----------|
| **Desktop** | Desktop + apps | systemd service | Usage local simple |
| **K3S Server** | K3S uniquement | K3S deployment | Production, orchestration |

### Configuration créée

1. **Profile k3s-server** (`profiles/k3s-server.nix`)
   - Mode headless (pas d'interface graphique)
   - GPU non utilisé par le système
   - Optimisations kernel pour Kubernetes
   - Outils de monitoring (htop, btop, nvtop)

2. **Service K3S** (`features/services/k3s.nix`)
   - Kubernetes léger (k3s)
   - Support GPU activé
   - Outils: kubectl, helm, k9s
   - Ports ouverts: 6443 (API), 10250 (kubelet), 8472 (flannel)

3. **NVIDIA Headless** (`features/hardware/nvidia-headless.nix`)
   - Drivers NVIDIA sans X/Wayland
   - 100% GPU dédié au compute (K3S)
   - NVIDIA Container Toolkit pour k3s
   - Persistence daemon activé

4. **Ollama**
   - **Mode Desktop**: Service systemd (`features/services/ollama.nix`) pour usage simple
   - **Mode Serveur**: Géré par K3S (via deployment yaml) - pas de service systemd

## Utilisation avec Specialisations (RECOMMANDÉ)

La machine `sleeper` est configurée avec **NixOS specialisations**, vous permettant de choisir au boot entre :
- **Mode Desktop** (par défaut) : Hyprland + GPU pour gaming/desktop
- **Mode K3S Server** : Headless + GPU 100% dédié à k3s/Ollama

### Activation

1. **Build la configuration avec les deux modes :**

```bash
sudo nixos-rebuild switch
```

2. **Reboot et choisir le mode au boot :**

Au démarrage, dans le menu **systemd-boot**, vous verrez :
```
NixOS
NixOS (k3s-server)  ← Choisir cette option
```

Utilisez les flèches ↑/↓ pour sélectionner `NixOS (k3s-server)` et appuyez sur Entrée.

3. **Revenir au mode Desktop :**

Redémarrez et sélectionnez simplement `NixOS` (sans suffixe) dans le menu de boot.

### Rendre un mode par défaut

Pour démarrer automatiquement en mode serveur :

```bash
# Démarrer en mode serveur au prochain boot
sudo /run/current-system/specialisation/k3s-server/bin/switch-to-configuration boot

# Retour au mode desktop par défaut
sudo /run/current-system/bin/switch-to-configuration boot
```

### Switcher sans redémarrer (avancé)

⚠️ **Attention** : Passer de desktop à serveur sans reboot arrêtera votre environnement graphique.

```bash
# Activer le mode serveur immédiatement (sans reboot)
sudo /run/current-system/specialisation/k3s-server/bin/switch-to-configuration switch

# Retour au mode desktop (nécessite reboot ou re-login)
sudo /run/current-system/bin/switch-to-configuration switch
```

## Méthode alternative : Reconfiguration manuelle

Si vous préférez une approche plus manuelle (non recommandé), vous pouvez utiliser `server-mode.nix` :

```bash
# 1. Sauvegarder la configuration actuelle
cp hosts/sleeper/default.nix hosts/sleeper/default.nix.desktop.bak

# 2. Activer le mode serveur
cp hosts/sleeper/server-mode.nix hosts/sleeper/default.nix

# 3. Rebuild et reboot
sudo nixos-rebuild switch
sudo reboot
```

## Après activation

### 1. Vérifier que k3s fonctionne

```bash
# Vérifier le cluster
sudo k3s kubectl get nodes

# Voir les pods système
sudo k3s kubectl get pods -A
```

### 2. Installer le NVIDIA Device Plugin

```bash
# Permet à k3s de découvrir et allouer les GPUs
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml

# Vérifier la détection du GPU
kubectl get nodes -o json | jq '.items[].status.capacity'
```

Vous devriez voir `nvidia.com/gpu: "1"` (ou plus selon votre config).

### 3. Vérifier Ollama

```bash
# Status du service
systemctl status ollama

# Tester Ollama
curl http://localhost:11434/api/version

# Télécharger un modèle
ollama pull llama2
```

### 4. Monitoring GPU

```bash
# Temps réel
nvidia-smi

# Interface interactive
nvtop

# Via k8s
kubectl run gpu-test --rm -ti --restart=Never \
  --image=nvidia/cuda:12.0.0-base-ubuntu22.04 \
  --limits=nvidia.com/gpu=1 -- nvidia-smi
```

## Déployer un LLM sur k3s

### Exemple: Ollama en tant que service k8s

Créez `ollama-deployment.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ollama
spec:
  selector:
    app: ollama
  ports:
    - port: 11434
      targetPort: 11434
  type: LoadBalancer
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      containers:
      - name: ollama
        image: ollama/ollama:latest
        ports:
        - containerPort: 11434
        resources:
          limits:
            nvidia.com/gpu: 1  # Demande 1 GPU
        volumeMounts:
        - name: ollama-data
          mountPath: /root/.ollama
      volumes:
      - name: ollama-data
        hostPath:
          path: /var/lib/ollama
          type: DirectoryOrCreate
```

Déployez:

```bash
kubectl apply -f ollama-deployment.yaml

# Vérifier
kubectl get pods
kubectl get svc
```

## Accès à distance

### SSH

```bash
ssh peuleu@<IP_SERVEUR>
```

### Kubeconfig pour accès distant

Sur le serveur:

```bash
# Copier le kubeconfig
sudo cat /etc/rancher/k3s/k3s.yaml
```

Sur votre machine locale:

```bash
# Éditer ~/.kube/config et remplacer 127.0.0.1 par l'IP du serveur
export KUBECONFIG=~/.kube/config
kubectl get nodes
```

## Retour au mode Desktop

Avec les specialisations, il suffit de **redémarrer et choisir "NixOS"** (sans suffixe) dans le menu de boot.

Aucune reconfiguration nécessaire !

## Conseils de performance

### 1. Modèles recommandés selon le GPU

- **8GB VRAM**: llama2:7b, mistral:7b, codellama:7b
- **12GB VRAM**: llama2:13b, vicuna:13b
- **16GB+ VRAM**: llama2:70b (quantized), mixtral:8x7b
- **24GB+ VRAM**: llama2:70b, gpt-j, falcon:40b

### 2. Optimiser Ollama

```bash
# Variables d'environnement (déjà configurées)
export OLLAMA_NUM_GPU=999
export OLLAMA_MAX_LOADED_MODELS=4
```

### 3. Monitoring continu

```bash
# Terminal 1: GPU utilization
watch -n 1 nvidia-smi

# Terminal 2: K8s pods
watch -n 2 kubectl get pods -A

# Terminal 3: System resources
htop
```

## Troubleshooting

### GPU non détecté par k3s

```bash
# Vérifier les drivers
nvidia-smi

# Vérifier le device plugin
kubectl get pods -n kube-system | grep nvidia

# Relancer le device plugin
kubectl delete -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml
```

### Ollama ne démarre pas

```bash
# Logs
journalctl -u ollama -f

# Redémarrer
sudo systemctl restart ollama
```

### K3S ne démarre pas

```bash
# Logs
journalctl -u k3s -f

# Reset complet (ATTENTION: supprime tous les workloads)
sudo systemctl stop k3s
sudo rm -rf /var/lib/rancher/k3s
sudo systemctl start k3s
```

## Ressources

- [K3s Documentation](https://docs.k3s.io/)
- [Ollama Documentation](https://github.com/ollama/ollama)
- [NVIDIA Device Plugin](https://github.com/NVIDIA/k8s-device-plugin)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/overview.html)
