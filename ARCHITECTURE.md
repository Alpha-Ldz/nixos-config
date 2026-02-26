# Architecture - Mode Desktop vs Mode K3S Server

## Philosophie de conception

Cette configuration suit le principe **"Un orchestrateur par mode"** pour éviter les conflits de ressources GPU.

### Mode Desktop : Simple & Direct

```
User → Ollama systemd service → GPU
         └─ Port 11434 (localhost)
```

**Caractéristiques :**
- Ollama tourne comme service systemd standard
- Accès direct via CLI : `ollama run llama2`
- API sur localhost:11434
- GPU partagé avec l'environnement graphique
- **Use case** : Développement local, tests rapides, usage interactif

**Avantages :**
- ✅ Simple à utiliser
- ✅ Pas de setup K8S nécessaire
- ✅ Accès immédiat
- ✅ Parfait pour dev/test

**Limitations :**
- ❌ GPU partagé (moins de performance)
- ❌ Pas de scaling
- ❌ Pas d'orchestration

### Mode K3S Server : Production & Orchestration

```
User → K3S → Ollama Pod → GPU
        ├─ API 6443
        ├─ NVIDIA Device Plugin
        └─ Autres workloads possibles
```

**Caractéristiques :**
- GPU 100% dédié à K3S
- K3S orchestre Ollama (et potentiellement d'autres workloads GPU)
- Pas de service Ollama systemd (évite les conflits)
- API via NodePort (accessible réseau)
- **Use case** : Production, orchestration multi-services, performance maximale

**Avantages :**
- ✅ GPU 100% dédié
- ✅ Performance maximale
- ✅ Orchestration K8S complète
- ✅ Scaling possible
- ✅ Monitoring centralisé
- ✅ Peut gérer plusieurs workloads GPU

**Limitations :**
- ❌ Setup initial plus complexe
- ❌ Overhead K8S (léger)

## Isolation des ressources

### GPU

| Mode | Allocation GPU |
|------|----------------|
| Desktop | Partagé : Hyprland + Apps + Ollama systemd |
| K3S Server | Dédié : K3S uniquement (headless, pas de GUI) |

### Stockage Ollama

Les modèles sont **isolés** entre les modes :

| Mode | Chemin | Géré par |
|------|--------|----------|
| Desktop | `/var/lib/ollama/` | systemd service |
| K3S Server | `/var/lib/ollama-k8s/` | K3S PersistentVolume |

**Pourquoi ?**
- Évite les conflits de lock de fichiers
- Isolation complète des données
- Permet des versions différentes d'Ollama si nécessaire

### Services

| Service | Desktop | K3S Server |
|---------|---------|------------|
| Hyprland | ✅ Active | ❌ Désactivé |
| Display Manager | ✅ Active | ❌ Désactivé |
| Ollama systemd | ✅ Active | ❌ Désactivé |
| K3S | ❌ Désactivé | ✅ Active |
| Docker | ✅ Active | ✅ Active (avec NVIDIA runtime) |
| SSH | ✅ Active | ✅ Active |

## Pourquoi ne pas partager Ollama entre les modes ?

### Option rejetée : Ollama systemd + K3S

```
❌ Mode Serveur : Ollama systemd + K3S
```

**Problèmes :**
1. **Conflit GPU** : Deux services veulent le GPU
2. **Conflit de port** : Ollama systemd (11434) vs Ollama K3S (NodePort)
3. **Gaspillage** : Ollama systemd inutilisé si tout passe par K3S
4. **Complexité** : Faut-il router vers systemd ou K3S ?
5. **Monitoring** : Deux sources de vérité

### Solution adoptée : Séparation claire

```
✅ Desktop  : Ollama systemd uniquement
✅ Serveur  : K3S gère tout
```

**Avantages :**
- Pas de conflit possible
- Rôles clairs et distincts
- Performance optimale dans chaque mode
- Architecture simple à comprendre

## Cas d'usage recommandés

### Choisir Mode Desktop quand :

- 🖥️ Vous travaillez localement sur la machine
- 🧪 Vous faites du développement/test
- 🎮 Vous avez besoin de l'interface graphique
- 🚀 Vous voulez utiliser Ollama rapidement sans setup

**Commandes typiques :**
```bash
ollama pull llama2
ollama run llama2 "Explain something"
```

### Choisir Mode K3S Server quand :

- 🏭 Vous voulez une performance GPU maximale
- 📊 Vous avez besoin d'orchestration K8S
- 🌐 Vous voulez exposer Ollama sur le réseau
- 🔄 Vous prévoyez de gérer plusieurs workloads GPU
- 📈 Vous voulez du monitoring/scaling professionnel

**Commandes typiques :**
```bash
kubectl get pods
./ollama-k8s-helper.sh deploy
./ollama-k8s-helper.sh run llama2
```

## Flux de travail recommandé

### Développement → Production

```
1. Mode Desktop
   └─ Prototyper et tester localement avec Ollama systemd
   └─ Développer vos applications

2. Mode K3S Server
   └─ Déployer sur K3S pour production
   └─ Performance maximale
   └─ Monitoring et orchestration
```

### Switch rapide

```bash
# Travailler en Desktop
→ Reboot → Choisir "NixOS"

# Déployer en prod
→ Reboot → Choisir "NixOS (k3s-server)"
```

## Architecture technique

### Mode Desktop

```
┌─────────────────────────────────────┐
│         NixOS (Desktop)             │
├─────────────────────────────────────┤
│ Hyprland (Wayland)                  │
│  ├─ Applications                    │
│  └─ GPU : rendering                 │
├─────────────────────────────────────┤
│ Services systemd                    │
│  ├─ ollama.service (GPU)            │
│  ├─ docker.service                  │
│  └─ sshd.service                    │
├─────────────────────────────────────┤
│ NVIDIA Drivers (with X/Wayland)     │
│  └─ GPU : Shared (desktop + apps)   │
└─────────────────────────────────────┘
```

### Mode K3S Server

```
┌─────────────────────────────────────┐
│      NixOS (K3S Server)             │
├─────────────────────────────────────┤
│ TTY (No GUI)                        │
│  └─ SSH access only                 │
├─────────────────────────────────────┤
│ K3S (Kubernetes)                    │
│  ├─ NVIDIA Device Plugin            │
│  ├─ Ollama Pod (GPU)                │
│  ├─ Other GPU workloads (possible)  │
│  └─ kubectl, helm, k9s              │
├─────────────────────────────────────┤
│ Services systemd                    │
│  ├─ k3s.service                     │
│  ├─ docker.service (NVIDIA runtime) │
│  └─ sshd.service                    │
├─────────────────────────────────────┤
│ NVIDIA Drivers (headless)           │
│  └─ GPU : 100% dedicated to K3S     │
└─────────────────────────────────────┘
```

## Résumé

| Aspect | Desktop | K3S Server |
|--------|---------|------------|
| **Objectif** | Dev/Test local | Production/Orchestration |
| **GPU** | Partagé | 100% dédié K3S |
| **Ollama** | systemd | K3S Pod |
| **Interface** | Hyprland GUI | TTY headless |
| **Complexité** | Simple | Avancé |
| **Performance** | Moyenne | Maximale |
| **Flexibilité** | Limitée | Haute (K8S) |

**Conclusion :** Deux modes distincts avec des rôles clairs, zéro conflit, performance optimale. 🎯
