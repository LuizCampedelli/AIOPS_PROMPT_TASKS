# Dockerfile
# Project: Lift — Hill Valley Tech
# Purpose: Containerise the Flask/Gunicorn API for Kubernetes deployment.
# Variables used (must be supplied at runtime — never baked into the image):
#   DATABASE_URL — PostgreSQL connection string
#   API_KEY      — Bearer token for request authentication
# Build:  docker build -t lift:latest .
# Run:    docker run -p 8080:8080 \
#           -e DATABASE_URL=postgres://user:pass@host:5432/db \
#           -e API_KEY=your-secret \
#           lift:latest

# ── Stage 1: dependency builder ────────────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /build

# Install only what is needed to compile psycopg2-binary wheels
RUN apt-get update && apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --prefix=/install --no-cache-dir -r requirements.txt

# ── Stage 2: runtime image ─────────────────────────────────────────────────────
FROM python:3.12-slim AS runtime

# Non-root user for least-privilege execution inside Kubernetes pods
RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app

# Copy installed packages from the builder stage
COPY --from=builder /install /usr/local

# Copy application source
COPY app.py .
COPY lib/ lib/

# Declare expected runtime environment variables (values are NOT set here)
ENV DATABASE_URL=""
ENV API_KEY=""

# Expose the application port
EXPOSE 8080

USER appuser

# Production entrypoint: 4 Gunicorn workers bound to all interfaces on port 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "app:app"]
