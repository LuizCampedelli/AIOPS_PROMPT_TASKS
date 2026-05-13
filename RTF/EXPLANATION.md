# EXPLANATION.md — Lift Service: RTF Prompt Output

## RTF Framework Breakdown

| Component | Applied as |
| --------- | ---------- |
| **Role**  | Senior DevOps engineer specialised in Docker, Kubernetes, and Python — framing technical decisions (multi-stage build, non-root user, env var injection) at production level |
| **Task**  | Produce a runnable Flask/Gunicorn application containerised for Kubernetes, with `DATABASE_URL` and `API_KEY` injected at runtime |
| **Format** | Complete project tree (`lift/`), variables and purpose documented at the top of every file, plus this EXPLANATION.md |

---

## Project Files

```
lift/
├── app.py              — Flask entry point; loads .env, registers routes
├── requirements.txt    — Pinned production dependencies
├── Dockerfile          — Multi-stage build → slim runtime image
├── lib/
│   ├── auth.py         — Bearer-token middleware (reads API_KEY)
│   └── storage.py      — psycopg2 helpers (reads DATABASE_URL)
└── tests/
    └── test_app.py     — pytest suite covering health, auth, and items route
```

---

## How to Build and Run

### Local (Docker)

```bash
# 1. Build the image
docker build -t lift:latest ./lift

# 2. Run with required environment variables
docker run -p 8080:8080 \
  -e DATABASE_URL="postgresql://user:pass@localhost:5432/lift" \
  -e API_KEY="your-secret-key" \
  lift:latest
```

Verify the liveness probe:

```bash
curl http://localhost:8080/health
# {"status": "ok"}
```

Call a protected endpoint:

```bash
curl -H "Authorization: Bearer your-secret-key" http://localhost:8080/items
```

---

### Kubernetes Deployment (recommended pattern)

Store secrets in a Kubernetes `Secret` object — never embed values in the image or `ConfigMap`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: lift-secrets
type: Opaque
stringData:
  DATABASE_URL: "postgresql://user:pass@db-service:5432/lift"
  API_KEY: "your-secret-key"
```

Reference the secret in your `Deployment`:

```yaml
env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: lift-secrets
        key: DATABASE_URL
  - name: API_KEY
    valueFrom:
      secretKeyRef:
        name: lift-secrets
        key: API_KEY
```

Configure liveness and readiness probes pointing at `/health`:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
readinessProbe:
  httpGet:
    path: /health
    port: 8080
```

---

## Dockerfile Design Decisions

| Decision | Reason |
| -------- | ------ |
| **Multi-stage build** | Compiler tools (`gcc`) stay in the builder stage; the runtime image is minimal |
| **`python:3.12-slim`** | Smaller attack surface vs. full Debian; sufficient for all pinned dependencies |
| **Non-root `appuser`** | Kubernetes best-practice — reduces blast radius if the container is compromised |
| **`ENV DATABASE_URL=""` / `ENV API_KEY=""`** | Documents required vars without embedding real values; runtime injection is mandatory |
| **`EXPOSE 8080`** | Matches Gunicorn bind and Flask default configured in the project |

---

## Running Tests

```bash
cd lift
pip install -r requirements.txt pytest
pytest tests/
```
