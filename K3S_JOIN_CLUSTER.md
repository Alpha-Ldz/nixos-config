# Rejoindre un cluster K3S existant

Ce guide explique comment configurer `sleeper` pour rejoindre un cluster K3S existant en tant que **worker node** avec GPU.

## Architecture

```
┌─────────────────────────┐
│   K3S Master Server     │
│   (Existing cluster)    │
│   - Control plane       │
│   - etcd                │
│   - API Server :6443    │
└───────────┬─────────────┘
            │
            │ Token + URL
            │
┌───────────▼─────────────┐
│   sleeper (Agent)       │
│   - GPU worker node     │
│   - Runs LLM workloads  │
│   - No control plane    │
└─────────────────────────┘
```

## Prérequis

### Sur le serveur K3S existant

1. **K3S server doit être en cours d'exécution**
2. **Port 6443 accessible** depuis sleeper (API server)
3. **Réseau** entre sleeper et le serveur

### Informations nécessaires

Vous avez besoin de :
- ✅ **IP ou hostname** du serveur K3S
- ✅ **Token** du cluster (pour authentification)

## Étape 1 : Obtenir le token du cluster

### Sur le serveur K3S existant

```bash
# Se connecter au serveur K3S
ssh user@your-k3s-server

# Récupérer le token
sudo cat /var/lib/rancher/k3s/server/node-token
```

Le token ressemble à :
```
K10abc123def456ghi789jkl012mno345pqr678stu901vwx234yz::server:1234567890abcdef
```

**Copiez ce token**, vous en aurez besoin.

### Alternative : Token via kubeconfig

Si vous avez accès au kubeconfig du cluster :

```bash
# Sur le serveur K3S
sudo cat /etc/rancher/k3s/k3s.yaml
```

## Étape 2 : Configurer sleeper

### 2.1 Éditer la configuration du cluster

Éditez le fichier `hosts/sleeper/k3s-cluster-config.nix` :

```nix
{ ... }:
{
  services.k3s-cluster = {
    # Remplacez par l'IP/hostname de votre serveur K3S
    serverUrl = "https://192.168.1.100:6443";  # CHANGEZ CETTE VALEUR !

    # Chemin vers le fichier contenant le token
    tokenFile = "/var/lib/rancher/k3s/token";
  };
}
```

**Remplacez `192.168.1.100`** par l'IP réelle de votre serveur K3S.

### 2.2 Créer le fichier token sur sleeper

Le token doit être stocké dans un fichier sécurisé :

```bash
# Créer le répertoire
sudo mkdir -p /var/lib/rancher/k3s

# Créer le fichier token avec le token copié à l'étape 1
echo "K10abc123def456ghi789jkl012mno345pqr678stu901vwx234yz::server:1234567890abcdef" | \
  sudo tee /var/lib/rancher/k3s/token

# Sécuriser le fichier
sudo chmod 600 /var/lib/rancher/k3s/token
sudo chown root:root /var/lib/rancher/k3s/token
```

**Remplacez le token** par celui obtenu à l'étape 1.

## Étape 3 : Build et activer la configuration

```bash
# Depuis /home/peuleu/nixos-config/
sudo nixos-rebuild switch --flake .#sleeper
```

Cela va builder la configuration avec le mode agent.

## Étape 4 : Démarrer en mode K3S Agent

```bash
# Redémarrer
sudo reboot

# Au menu de boot, choisir :
# "NixOS (k3s-server)"  ← Le nom reste "k3s-server" mais c'est maintenant un agent
```

## Étape 5 : Vérifier que le node a rejoint le cluster

### Sur sleeper (le nouveau node)

```bash
# Vérifier que K3S agent tourne
systemctl status k3s

# Les logs devraient montrer la connexion au serveur
journalctl -u k3s -f
```

Vous devriez voir des logs comme :
```
Successfully registered node with master
```

### Sur le serveur K3S

```bash
# Lister les nodes
kubectl get nodes

# Vous devriez voir sleeper dans la liste
NAME      STATUS   ROLES    AGE   VERSION
master    Ready    master   30d   v1.28.x
sleeper   Ready    <none>   1m    v1.28.x
```

## Étape 6 : Installer le NVIDIA Device Plugin

Le device plugin doit être installé **une seule fois** sur le cluster (pas sur chaque node).

### Si pas encore installé sur le cluster

```bash
# Sur n'importe quelle machine avec kubectl configuré
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml
```

### Vérifier que le GPU est détecté

```bash
# Vérifier la capacité GPU du node sleeper
kubectl get nodes sleeper -o json | jq '.status.capacity'

# Vous devriez voir :
{
  "nvidia.com/gpu": "1",  # ← Le GPU est détecté !
  ...
}
```

## Étape 7 : Tester le GPU

Déployez un pod de test sur sleeper :

```bash
# Créer un pod de test GPU
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-test
spec:
  nodeSelector:
    gpu: nvidia  # Sélectionne sleeper (voir labels dans k3s-agent.nix)
  containers:
  - name: cuda
    image: nvidia/cuda:12.0.0-base-ubuntu22.04
    command: ["nvidia-smi"]
    resources:
      limits:
        nvidia.com/gpu: 1
  restartPolicy: OnFailure
EOF

# Voir les logs (devrait afficher les infos GPU)
kubectl logs gpu-test

# Nettoyer
kubectl delete pod gpu-test
```

## Déployer Ollama sur le cluster

Maintenant que sleeper est un node du cluster, vous pouvez déployer Ollama :

```bash
cd /home/peuleu/nixos-config/examples/

# Déployer Ollama (il tournera sur sleeper grâce aux labels)
./ollama-k8s-helper.sh deploy
```

### Forcer Ollama à tourner sur sleeper

Éditez `examples/ollama-k8s-deployment.yaml` et ajoutez un nodeSelector :

```yaml
spec:
  template:
    spec:
      nodeSelector:
        gpu: nvidia        # Match le label du node sleeper
        # Ou plus spécifique :
        kubernetes.io/hostname: sleeper
      containers:
      ...
```

Puis redéployez :

```bash
kubectl apply -f examples/ollama-k8s-deployment.yaml
```

## Troubleshooting

### Le node n'apparaît pas dans kubectl get nodes

**Vérifier sur sleeper :**

```bash
# Status du service
systemctl status k3s

# Logs
journalctl -u k3s -f

# Vérifier la connectivité réseau
ping <ip-serveur-k3s>
curl -k https://<ip-serveur-k3s>:6443
```

**Problèmes courants :**

1. **Token invalide** : Vérifiez `/var/lib/rancher/k3s/token`
2. **Firewall** : Le port 6443 doit être ouvert sur le serveur
3. **URL incorrecte** : Vérifiez `k3s-cluster-config.nix`

### Le GPU n'est pas détecté

```bash
# Sur sleeper, vérifier nvidia-smi
nvidia-smi

# Vérifier les logs K3S
journalctl -u k3s | grep -i nvidia

# Vérifier que le device plugin tourne
kubectl get pods -n kube-system | grep nvidia
```

### Permission denied

Le fichier token doit être lisible par root uniquement :

```bash
sudo chmod 600 /var/lib/rancher/k3s/token
sudo chown root:root /var/lib/rancher/k3s/token
```

## Configuration avancée

### Labels personnalisés

Modifiez `features/services/k3s-agent.nix` pour ajouter des labels :

```nix
extraFlags = toString [
  "--node-label=gpu=nvidia"
  "--node-label=gpu-type=rtx3090"  # Exemple
  "--node-label=datacenter=home"
  "--node-label=tier=compute"
];
```

### Taints (empêcher certains pods de tourner sur sleeper)

```bash
# Sur le serveur K3S, ajouter un taint au node sleeper
kubectl taint nodes sleeper gpu=true:NoSchedule

# Seuls les pods avec une toleration correspondante pourront s'exécuter
```

## Accès au cluster depuis d'autres machines

### Copier le kubeconfig

```bash
# Sur le serveur K3S
sudo cat /etc/rancher/k3s/k3s.yaml

# Copier ce fichier sur votre machine locale
scp user@k3s-server:/etc/rancher/k3s/k3s.yaml ~/.kube/config

# Éditer et remplacer 127.0.0.1 par l'IP du serveur
vim ~/.kube/config
# Chercher "server: https://127.0.0.1:6443"
# Remplacer par "server: https://<ip-serveur>:6443"

# Tester
kubectl get nodes
```

## Résumé des fichiers modifiés

1. **`features/services/k3s-agent.nix`** - Configuration K3S en mode agent
2. **`hosts/sleeper/k3s-cluster-config.nix`** - URL et token du cluster
3. **`hosts/sleeper/default.nix`** - Utilise k3s-agent au lieu de k3s

## Commandes utiles

```bash
# Status du node
kubectl get nodes
kubectl describe node sleeper

# Pods tournant sur sleeper
kubectl get pods --all-namespaces --field-selector spec.nodeName=sleeper

# Labels du node
kubectl get node sleeper --show-labels

# Ressources GPU disponibles
kubectl describe node sleeper | grep -A 5 "Capacity"

# Vérifier les events
kubectl get events --sort-by='.lastTimestamp' | grep sleeper
```

## Retour au mode standalone (optionnel)

Si vous voulez revenir à un cluster K3S standalone sur sleeper :

1. Éditez `hosts/sleeper/default.nix`
2. Remplacez `k3s-agent.nix` par `k3s.nix`
3. Supprimez l'import de `k3s-cluster-config.nix`
4. Rebuild : `sudo nixos-rebuild switch --flake .#sleeper`

---

Vous êtes maintenant prêt à utiliser sleeper comme worker node GPU dans votre cluster K3S ! 🚀
