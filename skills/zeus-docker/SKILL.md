---
name: zeus-docker
description: Expert Docker and containerization reference. Covers images, containers, Dockerfiles, Docker Compose, networking, volumes, security, and production patterns.
---

---

## Core Concepts

### Image vs Container

| Concept | Analogy | Properties |
|---|---|---|
| **Image** | Recipe/Blueprint | Read-only template, layered, immutable |
| **Container** | Running instance | Runnable process, isolated, ephemeral |

**Key insight**: Multiple containers can run from the same image.

### Docker Architecture

- **Client**: CLI (`docker run`, `docker build`, etc.)
- **Daemon**: Background service that manages containers
- **Registry**: Storage for images (Docker Hub is default)
- **Layers**: Images are built layer-by-layer for efficiency

---

## Essential Commands

### Container Lifecycle

```bash
# Run containers
docker run hello-world                    # Basic run
docker run -d nginx                       # Detached (background)
docker run -p 8080:80 nginx               # Port mapping (host:container)
docker run -it ubuntu bash                # Interactive terminal
docker run --name myapp nginx             # Named container
docker run -e VAR=value nginx            # Environment variable
docker run -v /host/path:/container/path nginx  # Volume mount

# Manage containers
docker ps                                 # List running containers
docker ps -a                              # List ALL containers
docker stop <id>                          # Stop gracefully
docker kill <id>                          # Force stop
docker rm <id>                            # Remove container
docker restart <id>                        # Stop then start

# Interact with running containers
docker exec -it <id> bash                 # Shell into container
docker logs <id>                          # View logs
docker logs -f <id>                       # Follow logs
docker inspect <id>                       # Detailed info
docker stats <id>                         # Resource usage
```

### Image Management

```bash
# Image operations
docker images                             # List local images
docker pull nginx:latest                  # Download from registry
docker build -t myapp:1.0 .              # Build from Dockerfile
docker tag myapp:1.0 user/myapp:latest   # Tag for push
docker push user/myapp:latest             # Upload to registry
docker rmi <image>                       # Remove image
docker image prune                        # Clean unused images

# Inspect images
docker history myapp:1.0                  # Show layers
docker inspect myapp:1.0                  # Full metadata
```

---

## Dockerfile Deep Dive

### Key Instructions

| Instruction | Purpose | Example |
|---|---|---|
| `FROM` | Base image | `FROM python:3.12-slim` |
| `RUN` | Execute during build | `RUN pip install -r reqs.txt` |
| `COPY` | Copy files from host | `COPY ./src /app/src` |
| `WORKDIR` | Set working directory | `WORKDIR /app` |
| `ENV` | Environment variable | `ENV NODE_ENV=production` |
| `EXPOSE` | Document ports | `EXPOSE 8080` |
| `CMD` | Default command | `CMD ["python", "app.py"]` |
| `ENTRYPOINT` | Fixed executable | `ENTRYPOINT ["python"]` |
| `ARG` | Build-time variable | `ARG VERSION` |
| `USER` | Set user/group | `USER node` |

### Example: Node.js App

```dockerfile
# syntax=docker/dockerfile:1
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

USER node
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Multi-Stage Builds

```dockerfile
# Build stage
FROM golang:1.21 AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o app

# Runtime stage
FROM alpine:latest
COPY --from=builder /src/app /app/
CMD ["/app/app"]
```

### Best Practices

1. **Use slim/alpine images** — Smaller attack surface
2. **Order layers wisely** — Put rarely-changing first (caching)
3. **Use `.dockerignore`** — Exclude `node_modules`, `.git`, etc.
4. **Don't run as root** — Use `USER` directive
5. **Multi-stage builds** — Separate build from runtime
6. **Specific tags** — Avoid `:latest` in production

---

## Docker Compose

### Basic Structure

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8080:8000"
    environment:
      - DB_HOST=db
      - REDIS_URL=redis://cache:6379
    volumes:
      - ./src:/app/src
    depends_on:
      - db
      - cache
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  cache:
    image: redis:7-alpine

volumes:
  postgres_data:
```

### Key Compose Commands

```bash
docker compose up -d              # Start all services (detached)
docker compose down               # Stop and remove
docker compose down -v            # Also remove volumes
docker compose up --build         # Rebuild before start
docker compose ps                 # Show status
docker compose logs -f web        # Follow service logs
docker compose exec web bash      # Shell into service
docker compose restart web        # Restart specific service
docker compose pull               # Pull latest images
docker compose top                # Show processes
```

### Advanced Patterns

**Health checks:**
```yaml
services:
  db:
    image: postgres:15
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
```

**Scaling:**
```bash
docker compose up -d --scale worker=3
```

**Multiple compose files:**
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up
```

---

## Networking

### Network Types

| Driver | Use Case |
|---|---|
| `bridge` | Default, single-host containers |
| `host` | Remove network isolation |
| `overlay` | Multi-host (Docker Swarm) |
| `none` | Disable networking |

### Service Communication

Containers communicate via service names:
```yaml
services:
  web:
    links:
      - db
  # web can reach db at hostname "db"
```

Or just rely on default DNS:
```yaml
services:
  web:
    environment:
      - DATABASE_URL=postgres://db:5432/myapp
  db:
    # No explicit links needed - DNS auto-discovery
```

---

## Volumes & Storage

### Volume Types

```bash
# Named volume (persistent)
docker run -v mydata:/var/lib/data postgres

# Bind mount (host path)
docker run -v /host/data:/container/data nginx

# tmpfs (memory-only)
docker run --tmpfs /run:rw,noexec,nosuid,size=64m nginx
```

### In Compose

```yaml
services:
  db:
    image: postgres:15
    volumes:
      - db_data:/var/lib/postgresql/data
      - ./backups:/backups

volumes:
  db_data:
```

---

## Security Best Practices

```dockerfile
# Use specific, minimal base images
FROM python:3.12-slim-bookworm

# Create non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
USER appuser

# Copy files as non-root
COPY --chown=appuser:appgroup src ./src

# No secrets in ENV (use runtime secrets)
# ENV DB_PASSWORD=secret  # BAD
# Use: docker run -e DB_PASSWORD=$SECRET
```

```bash
# Security scanning
docker scout cves myapp:1.0
docker scout recommendations myapp:1.0
```

---

## Troubleshooting

```bash
# Debugging
docker logs <container>                    # Application logs
docker inspect <container>                 # Full details
docker diff <container>                    # Files changed
docker port <container>                     # Port mappings

# Resource issues
docker stats                               # Live resource usage
docker system df                           # Disk usage
docker system prune                        # Clean up

# Networking
docker network ls
docker network inspect bridge
docker exec <id> cat /etc/hosts
```

---

## Quick Reference Tables

### Common Image Tags

| Tag | Meaning |
|---|---|
| `alpine` | Minimal (~5MB) |
| `slim` | Minimal without docs |
| `-bookworm` | Debian 12 (stable) |
| `-buster` | Debian 11 (oldstable) |
| `:3.12` | Specific version |
| `:latest` | Default version (avoid in production) |

### Port Mapping Format

```
-p HOST:CONTAINER
-p 8080:80      # Host 8080 → Container 80
-p 127.0.0.1:80:80  # Bind to localhost only
-p 8080-8085:80    # Range mapping
```

### Restart Policies

| Policy | Behavior |
|---|---|
| `no` | Never restart |
| `always` | Always restart |
| `unless-stopped` | Restart unless manually stopped |
| `on-failure` | Restart on non-zero exit |

---

## Common Patterns

### Python + PostgreSQL

```dockerfile
# Dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app.wsgi"]
```

```yaml
# docker-compose.yml
services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgres://user:pass@db:5432/myapp
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: myapp
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
```

### Node.js + Redis

```yaml
services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      REDIS_URL: redis://cache:6379
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      - cache

  cache:
    image: redis:7-alpine
```

---

## When to Use What

| Scenario | Solution |
|---|---|
| Single container | `docker run` |
| Multi-container local dev | Docker Compose |
| Multi-host production | Kubernetes / Docker Swarm |
| Simple CI/CD | Docker in GitHub Actions |
| Complex orchestration | Compose + Swarm/K8s |

---

## Official Resources

- Docs: https://docs.docker.com/
- Best practices: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
- Compose reference: https://docs.docker.com/compose/compose-file/
- Docker Hub: https://hub.docker.com/

---

End of skill.
