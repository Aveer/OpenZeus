---
name: zeus-llm
description: Reference and workflows for LLaMA tooling: llama.cpp HTTP server, llama-swap, and Ollama installation and configuration.
---

---

## LLaMA.cpp HTTP Server

### Install llama.cpp

```bash
# Clone and build
git clone https://github.com/ggml-org/llama.cpp.git
cd llama.cpp
mkdir build && cd build
cmake ..
cmake --build . --config Release

# Or use pre-built binaries
# Download from: https://github.com/ggml-org/llama.cpp/releases
```

### Start HTTP Server

```bash
# Basic server
./llama-server -m model.gguf -c 4096 --host 0.0.0.0 --port 8080

# With GPU support (CUDA)
./llama-server -m model.gguf -c 4096 --ngl 99 --host 0.0.0.0 --port 8080

# With more context
./llama-server -m model.gguf -c 8192 -fa --host 0.0.0.0 --port 8080
```

### Common Server Flags

| Flag | Description | Example |
|---|---|---|
| `-m` | Model path | `-m models/llama-7b.gguf` |
| `-c` | Context size | `-c 4096` |
| `--host` | Listen address | `--host 0.0.0.0` |
| `--port` | Listen port | `--port 8080` |
| `--ngl` | GPU layers | `--ngl 99` |
| `-fa` | Flash attention | `-fa` |
| `-t` | Threads | `-t 8` |
| `-b` | Batch size | `-b 512` |
| `--parallel` | Parallel requests | `--parallel 4` |

### API Endpoints

```bash
# Chat completions (OpenAI-compatible)
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "model-name",
    "messages": [{"role": "user", "content": "Hello"}]
  }'

# Completions
curl http://localhost:8080/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "model-name",
    "prompt": "The capital of France is"
  }'

# Embeddings
curl http://localhost:8080/v1/embeddings \
  -H "Content-Type: application/json" \
  -d '{
    "model": "model-name",
    "input": "The quick brown fox"
  }'

# List models
curl http://localhost:8080/v1/models
```

---

## llama-swap

### Purpose

llama-swap is a proxy server that routes LLM requests to multiple backend servers based on load, cost, or custom rules.

### Install

```bash
npm install -g llama-swap
# or
pip install llama-swap
```

### Configuration File

```yaml
# llama-swap.yaml
listen: 0.0.0.0:5000

backends:
  - name: local-llama
    url: http://localhost:8080/v1
    priority: 1
    models:
      - llama-7b
      - llama-13b
    max_tokens: 4096

  - name: openai-backup
    url: http://localhost:11434/v1
    priority: 2
    models:
      - gpt-3.5-turbo

routing:
  strategy: priority  # priority | round-robin | least-load
  fallback: true

cache:
  enabled: true
  ttl: 3600
```

### OpenCode Provider Config

```json
{
  "provider": {
    "llama-swap": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "llama-swap (local)",
      "options": {
        "baseURL": "http://localhost:5000/v1",
        "apiKey": "not-required"
      },
      "models": {
        "llama-7b": {
          "name": "LLaMA 7B",
          "family": "llama",
          "attachment": true,
          "tool_call": true,
          "limit": {
            "context": 4096,
            "output": 2048
          }
        }
      }
    }
  }
}
```

---

## Ollama

### Install

```bash
# macOS/Linux
curl -fsSL https://ollama.ai/install.sh | sh

# Docker
docker run -d -v ollama:/root/.ollama -p 11434:11434 ollama/ollama
```

### Common Commands

```bash
# Pull a model
ollama pull llama3.2:1b

# List models
ollama list

# Run interactively
ollama run llama3.2:1b

# Create custom model
ollama create my-model -f Modelfile
```

### Ollama API

```bash
# Chat
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2:1b",
  "messages": [{"role": "user", "content": "Hello"}]
}'

# Generate
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "The capital of France is"
}'

# Embeddings
curl http://localhost:11434/api/embeddings -d '{
  "model": "llama3.2:1b",
  "prompt": "The quick brown fox"
}'
```

### OpenAI-Compatible API

```bash
# Use Ollama with OpenAI-compatible endpoint
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2:1b",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

---

## OpenCode Integration Examples

### llama.cpp with OpenCode

```json
{
  "provider": {
    "llama-cpp": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "llama.cpp server",
      "options": {
        "baseURL": "http://localhost:8080/v1",
        "apiKey": "not-required"
      },
      "models": {
        "qwen-7b": {
          "name": "Qwen 7B",
          "family": "qwen",
          "attachment": true,
          "tool_call": true,
          "limit": {
            "context": 8192,
            "output": 2048
          }
        }
      }
    }
  }
}
```

### Ollama with OpenCode

```json
{
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama",
      "options": {
        "baseURL": "http://localhost:11434/v1",
        "apiKey": "not-required"
      },
      "models": {
        "llama3.2:1b": {
          "name": "LLaMA 3.2 1B",
          "family": "llama",
          "attachment": true,
          "tool_call": false,
          "limit": {
            "context": 8192,
            "output": 2048
          }
        }
      }
    }
  }
}
```

---

## Verification Commands

```bash
# Check if llama.cpp server is running
curl http://localhost:8080/v1/models

# Check if Ollama is running
curl http://localhost:11434/api/tags

# Check llama-swap status
curl http://localhost:5000/status

# Test a completion
curl http://localhost:8080/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "test", "prompt": "Hello"}'
```

---

## Common Pitfalls

| Issue | Solution |
|---|---|
| Model not found | Check path with `-m` flag; use absolute path |
| Out of memory | Reduce context size `-c` or GPU layers `--ngl` |
| Slow inference | Increase threads `-t`, enable flash attention `-fa` |
| Connection refused | Ensure server is running; check port binding |
| Token limit exceeded | Reduce context size or use larger model |
| CUDA not available | Install CUDA toolkit; ensure GPU drivers |

---

## Relevant URLs

| Resource | URL |
|---|---|
| llama.cpp releases | https://github.com/ggml-org/llama.cpp/releases |
| llama.cpp server README | https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md |
| llama-swap docs | https://github.com/mostlygeek/llama-swap/blob/main/docs/configuration.md |
| Ollama docs | https://github.com/ollama/ollama/blob/main/docs/api.md |

---

End of skill.
