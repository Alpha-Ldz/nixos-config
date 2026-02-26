# Exemples K3S + Ollama

Ce dossier contient des exemples et scripts pour déployer et gérer Ollama sur votre cluster K3S.

## Fichiers

### `ollama-k8s-deployment.yaml`
Manifeste Kubernetes complet pour déployer Ollama avec support GPU.

**Caractéristiques:**
- Namespace dédié `llm`
- PersistentVolume pour stocker les modèles (100GB)
- GPU allocation (1 GPU)
- NodePort service (accessible via `<node-ip>:31434`)
- Health checks (liveness & readiness probes)

### `ollama-k8s-helper.sh`
Script utilitaire pour gérer Ollama sur K3S facilement.

## Démarrage rapide

### 1. Déployer Ollama

```bash
cd examples/

# Déployer Ollama sur K3S
./ollama-k8s-helper.sh deploy

# Vérifier le déploiement
./ollama-k8s-helper.sh status
```

### 2. Télécharger et utiliser un modèle

```bash
# Télécharger un modèle
./ollama-k8s-helper.sh pull llama2

# Lister les modèles installés
./ollama-k8s-helper.sh list

# Tester le modèle
./ollama-k8s-helper.sh run llama2 "Explain Kubernetes in simple terms"
```

### 3. Test rapide

```bash
# Test complet avec tinyllama (modèle léger)
./ollama-k8s-helper.sh quick-test
```

## Commandes utiles

```bash
# Voir les logs
./ollama-k8s-helper.sh logs

# Accès shell dans le pod
./ollama-k8s-helper.sh shell

# Tester l'accès GPU
./ollama-k8s-helper.sh test-gpu

# Supprimer un modèle
./ollama-k8s-helper.sh remove-model llama2

# Supprimer le déploiement
./ollama-k8s-helper.sh remove
```

## Accès à l'API Ollama

Une fois déployé, Ollama est accessible via:

```bash
# Via NodePort (depuis n'importe quelle machine du réseau)
curl http://<node-ip>:31434/api/version

# Depuis un pod dans le cluster
curl http://ollama.llm.svc.cluster.local:11434/api/version

# Via port-forward (pour accès local)
kubectl port-forward -n llm svc/ollama 11434:11434
curl http://localhost:11434/api/version
```

## Utilisation depuis votre code

### Python

```python
import requests

# Via NodePort
OLLAMA_URL = "http://<node-ip>:31434"

# Ou via port-forward
# OLLAMA_URL = "http://localhost:11434"

def query_ollama(model, prompt):
    response = requests.post(
        f"{OLLAMA_URL}/api/generate",
        json={"model": model, "prompt": prompt, "stream": False}
    )
    return response.json()["response"]

result = query_ollama("llama2", "What is Kubernetes?")
print(result)
```

### JavaScript/Node.js

```javascript
const axios = require('axios');

const OLLAMA_URL = 'http://<node-ip>:31434';

async function queryOllama(model, prompt) {
  const response = await axios.post(`${OLLAMA_URL}/api/generate`, {
    model: model,
    prompt: prompt,
    stream: false
  });
  return response.data.response;
}

queryOllama('llama2', 'What is Kubernetes?')
  .then(result => console.log(result));
```

### Curl

```bash
# Generate response
curl http://<node-ip>:31434/api/generate -d '{
  "model": "llama2",
  "prompt": "What is Kubernetes?",
  "stream": false
}'

# Chat completion
curl http://<node-ip>:31434/api/chat -d '{
  "model": "llama2",
  "messages": [
    {"role": "user", "content": "Why is the sky blue?"}
  ],
  "stream": false
}'
```

## Modèles recommandés

| Modèle | Taille | VRAM requis | Usage |
|--------|--------|-------------|-------|
| tinyllama | 1.1B | ~2GB | Tests, prototypage |
| llama2:7b | 7B | ~8GB | Usage général |
| mistral:7b | 7B | ~8GB | Haute qualité |
| codellama:7b | 7B | ~8GB | Code generation |
| llama2:13b | 13B | ~16GB | Meilleure qualité |
| mixtral:8x7b | 47B | ~24GB | Très haute qualité |

## Monitoring

### GPU utilization

```bash
# Dans le pod Ollama
./ollama-k8s-helper.sh shell
nvidia-smi

# Ou directement
./ollama-k8s-helper.sh test-gpu
```

### Métriques K8S

```bash
# CPU/Mémoire du pod
kubectl top pod -n llm

# Événements
kubectl get events -n llm --sort-by='.lastTimestamp'
```

## Troubleshooting

### Pod ne démarre pas

```bash
# Voir les events
kubectl describe pod -n llm -l app=ollama

# Vérifier que le GPU est disponible
kubectl get nodes -o json | jq '.items[].status.capacity | ."nvidia.com/gpu"'
```

### GPU non détecté

```bash
# Vérifier le NVIDIA device plugin
kubectl get pods -n kube-system | grep nvidia

# Redéployer si nécessaire
kubectl delete -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml
```

### Modèle trop lent

- Vérifiez que le GPU est utilisé: `./ollama-k8s-helper.sh test-gpu`
- Vérifiez l'utilisation GPU pendant l'inférence: `watch -n 1 nvidia-smi`
- Essayez un modèle plus petit (tinyllama, llama2:7b)
- Vérifiez les resources limits/requests dans le deployment

## Personnalisation

### Augmenter le stockage

Éditez `ollama-k8s-deployment.yaml`:

```yaml
spec:
  capacity:
    storage: 200Gi  # Au lieu de 100Gi
```

### Utiliser plusieurs GPUs

Éditez `ollama-k8s-deployment.yaml`:

```yaml
resources:
  limits:
    nvidia.com/gpu: 2  # Au lieu de 1
```

### Changer le port NodePort

Éditez `ollama-k8s-deployment.yaml`:

```yaml
spec:
  ports:
    - nodePort: 32000  # Au lieu de 31434
```

## Ressources

- [Ollama API Documentation](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [Ollama Model Library](https://ollama.com/library)
- [K3s Documentation](https://docs.k3s.io/)
