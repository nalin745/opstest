
## Endpoints

| Endpoint | Purpose |
|---|---|
| `GET /health` | Liveness — cheap, no downstream dependency checks. This is what the Terraform ALB module's `health_check_path` targets. |
| `GET /health/ready` | Readiness — `503` until startup finishes / after shutdown begins. Suitable for a stricter orchestrator-level readiness gate. |
| `GET /metrics` | Prometheus-format metrics (request count + latency histogram), for Task 4. |
| `GET/POST /api/v1/tasks`, `GET/PATCH/DELETE /api/v1/tasks/{id}` | Sample CRUD resource. |

## Configuration

All config is environment-driven (`APP_` prefix), so one image is promoted
unchanged across environments:

| Variable | Default | Notes |
|---|---|---|
| `APP_PORT` | `8080` | Matches the `application_port` Terraform variable. |
| `APP_ENVIRONMENT` | `local` | Set to `dev` / `staging` / `prod` by the ECS task definition. |
| `APP_LOG_LEVEL` | `INFO` | Structured JSON logs to stdout. |
| `APP_APP_VERSION` | `0.1.0` | Surfaced on `/health`; set to the image tag/git SHA at build time in CI. |

## Running locally

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt
uvicorn app.main:app --reload --port 8080
```

Tests:

```bash
pytest
```

## Running the container

```bash
docker build -t rightmo-sample-app:local .
docker run --rm -p 8080:8080 rightmo-sample-app:local
```

Or with the production-like constraints applied (read-only root
filesystem, no new privileges, all capabilities dropped):

```bash
docker compose up --build
```




