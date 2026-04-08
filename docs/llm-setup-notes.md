# Notes LLM Setup - Session du 2026-04-07

## Configuration matérielle

- **GPU 1:** RTX 4080 SUPER (16 GB VRAM)
- **GPU 2:** RTX 5090 (32 GB VRAM)
- **Total:** 48 GB VRAM

---

## Problème Multi-GPU avec Ollama/llama.cpp

### Constat
- Ollama utilise **layer split** (séquentiel), pas de tensor parallelism
- GPU 1 travaille → GPU 2 attend → GPU 1 attend → etc.
- Avec GPUs de générations différentes, c'est encore pire

### Solutions possibles
| Solution | Status |
|----------|--------|
| vLLM (tensor parallelism) | Ne marche pas bien avec GPUs hétérogènes |
| Utiliser 1 seul GPU (5090) | **Recommandé** |
| 2x GPUs identiques | Idéal mais coûteux |

### Sources
- https://www.ahmadosman.com/blog/do-not-use-llama-cpp-or-ollama-on-multi-gpus-setups-use-vllm-or-exllamav2/
- https://discuss.vllm.ai/t/combining-2-different-gpus/1609

---

## Quantization des modèles

### Formats disponibles (bits par poids)

| Format | Bits/poids | Qualité | Usage |
|--------|-----------|---------|-------|
| Q8_0 | 8 | Excellent | Référence |
| Q6_K | 6 | Très bon | Production |
| Q5_K_M | 5.5 | Très bon | Bon compromis |
| **Q4_K_M** | 4.85 | Bon | **Standard Ollama** |
| IQ3_XXS | 3.06 | Acceptable | Modèles larges sur GPU limité |
| IQ2_M | 2.93 | Dégradé | Extrême |
| Q2_K | 3.16 | Dégradé | Extrême |
| IQ1_S | 2.00 | Très dégradé | Dernier recours |

### Impact de la quantization

| Aspect | Q4+ | Q3 | Q2 | Q1 |
|--------|-----|----|----|-----|
| Raisonnement complexe | OK | -10% | -20% | -40% |
| Coding/STEM | OK | -15% | -25% | -50% |
| Cohérence | OK | OK | -10% | -30% |
| Vitesse | Base | +10% | +15% | +20% |

### IQ vs Q (Importance Matrix)
- **IQ** = utilise une matrice d'importance (préserve les poids critiques)
- **Q** = quantization uniforme
- **IQ2_M > Q2_K** en qualité pour la même taille

---

## KV Cache Quantization

### C'est quoi ?
Le KV cache stocke le contexte (tokens précédents). Il grossit linéairement avec la longueur du contexte.

### Options Ollama

| Type | Mémoire | Qualité | Variable |
|------|---------|---------|----------|
| f16 (défaut) | 100% | Parfait | - |
| q8_0 | 50% | Quasi parfait | `OLLAMA_KV_CACHE_TYPE=q8_0` |
| q4_0 | 33% | Légère perte | `OLLAMA_KV_CACHE_TYPE=q4_0` |

### Activation
```nix
# Dans ollama-server.nix
environment.OLLAMA_KV_CACHE_TYPE = "q8_0";
environment.OLLAMA_FLASH_ATTENTION = "1";  # Requis pour KV quant
```

### TurboQuant (futur)
- Compression 6x du KV cache
- Pas encore intégré dans Ollama
- Arrive bientôt dans llama.cpp

---

## Qwen3-Coder-Next (80B)

### Quantizations disponibles pour 32GB VRAM

| Format | Taille | Rentre dans 32GB |
|--------|--------|------------------|
| q4_K_M | 51 GB | Non |
| **IQ3_XXS** | 28.5 GB | **Oui** (recommandé) |
| IQ2_M | 25 GB | Oui |
| Q2_K | 29.2 GB | Oui |

### Téléchargement manuel (pas sur Ollama)
```bash
# Depuis HuggingFace
wget https://huggingface.co/unsloth/Qwen3-Coder-Next-GGUF/resolve/main/Qwen3-Coder-Next-UD-IQ3_XXS.gguf

# Créer Modelfile
echo 'FROM ./Qwen3-Coder-Next-UD-IQ3_XXS.gguf' > Modelfile

# Importer dans Ollama
ollama create qwen3-coder-next:iq3_xxs -f Modelfile
```

### Sources
- https://huggingface.co/unsloth/Qwen3-Coder-Next-GGUF

---

## Thermal Monitor (implémenté)

Service NixOS créé: `features/services/thermal-monitor.nix`

### Seuils configurés
| Composant | Warning | Critical | Emergency |
|-----------|---------|----------|-----------|
| GPU | 78°C | 85°C | 90°C |
| CPU | 80°C | 90°C | 95°C |

### Commandes utiles
```bash
systemctl status thermal-monitor
journalctl -u thermal-monitor -f
tail -f /var/log/thermal-monitor/metrics.log
```

---

## TODO

- [ ] Redimensionner partition (récupérer espace Windows)
- [ ] Télécharger Qwen3-Coder-Next IQ3_XXS
- [ ] Configurer KV cache q8_0 dans Ollama
- [ ] Tester performance avec `ollama launch claude`

---

## Ressources utiles

- [llama.cpp Quantization](https://github.com/ggml-org/llama.cpp/blob/master/tools/quantize/README.md)
- [Ollama KV Cache](https://smcleod.net/2024/12/bringing-k/v-context-quantisation-to-ollama/)
- [Unsloth GGUF Models](https://huggingface.co/unsloth)
- [TurboQuant](https://research.google/blog/turboquant-redefining-ai-efficiency-with-extreme-compression/)
