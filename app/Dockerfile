# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Stage 1: builder
# Installs dependencies into an isolated virtualenv so the runtime stage
# never needs pip, setuptools, or any build tooling baked into it.
# ---------------------------------------------------------------------------
FROM python:3.12-slim AS builder

ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /build

COPY requirements.txt .

RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# ---------------------------------------------------------------------------
# Stage 2: runtime
# Minimal, non-root, no package manager or build tooling present.
# ---------------------------------------------------------------------------
FROM python:3.12-slim AS runtime

# A dedicated, unprivileged, non-login system user/group. ECS Fargate and
# most orchestrators default to running as root if the image doesn't
# specify otherwise, which this deliberately avoids.
RUN addgroup --system app \
    && adduser --system --ingroup app --no-create-home --shell /usr/sbin/nologin app

ENV PATH="/opt/venv/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_PORT=8080

COPY --from=builder /opt/venv /opt/venv

WORKDIR /app
COPY app ./app

# No writable state is needed at runtime: the app is stateless (in-memory
# store, no local file writes), so the container is designed to run with
# a read-only root filesystem (see docker-compose.yml / the ECS task
# definition's `readonlyRootFilesystem: true`).
USER app

EXPOSE 8080

# Orchestrator-agnostic container-level health check. ECS/Kubernetes will
# typically also probe /health via the ALB target group or a
# livenessProbe, but this makes the image self-describing even when run
# standalone (e.g. `docker run`) or under plain Docker/Swarm.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=2)"]

# Exec form: uvicorn runs as PID 1 and receives SIGTERM directly from the
# orchestrator, so it can begin graceful shutdown (see app/main.py's
# lifespan handler) instead of the signal being swallowed by a shell.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080", "--proxy-headers", "--forwarded-allow-ips=*"]
