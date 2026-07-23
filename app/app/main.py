import logging
import time
import uuid
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, PlainTextResponse
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

from app.config import get_settings
from app.logging_config import configure_logging
from app.routers import tasks

settings = get_settings()
configure_logging(settings.log_level)
logger = logging.getLogger("app")

# Readiness starts false: the ALB target group should not receive traffic
# until startup work (below) has actually finished.
_ready = False

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "path", "status_code"],
)
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency in seconds",
    ["method", "path"],
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    global _ready
    logger.info("Starting up", extra={"path": "startup"})
    # Placeholder for real startup work: DB connection pool warm-up,
    # cache pre-fill, migration checks, etc.
    _ready = True
    logger.info("Ready to accept traffic", extra={"path": "startup"})

    yield

    # On SIGTERM, ECS/the orchestrator stops sending new traffic and gives
    # the process a grace period before SIGKILL. Flip readiness off first
    # so the ALB deregisters us, then let in-flight requests finish.
    _ready = False
    logger.info("Shutting down", extra={"path": "shutdown"})


app = FastAPI(
    title="Rightmo Sample Service",
    version=settings.app_version,
    lifespan=lifespan,
)


@app.middleware("http")
async def request_logging_middleware(request: Request, call_next):
    request_id = request.headers.get("x-request-id", str(uuid.uuid4()))
    start = time.perf_counter()

    response = await call_next(request)

    duration_ms = round((time.perf_counter() - start) * 1000, 2)
    route = request.scope.get("route")
    path_template = route.path if route else request.url.path

    REQUEST_COUNT.labels(request.method, path_template, response.status_code).inc()
    REQUEST_LATENCY.labels(request.method, path_template).observe(duration_ms / 1000)

    logger.info(
        "request handled",
        extra={
            "request_id": request_id,
            "path": request.url.path,
            "method": request.method,
            "status_code": response.status_code,
            "duration_ms": duration_ms,
        },
    )

    response.headers["x-request-id"] = request_id
    return response


@app.get("/health", tags=["operations"])
def liveness() -> JSONResponse:
    """Liveness probe: process is up and able to serve HTTP.

    This is the path configured as `health_check_path` on the ALB target
    group, and is intentionally cheap — it must never depend on a
    downstream dependency, or a slow database would take down a perfectly
    healthy app instance.
    """
    return JSONResponse({"status": "ok", "version": settings.app_version})


@app.get("/health/ready", tags=["operations"])
def readiness() -> JSONResponse:
    """Readiness probe: process is up AND ready to receive real traffic.

    Suitable for an orchestrator-level readiness gate (e.g. an ECS/ALB
    target group health check with a stricter grace period, or a
    Kubernetes readinessProbe) that should hold back traffic during
    startup and during graceful shutdown.
    """
    if not _ready:
        return JSONResponse({"status": "not_ready"}, status_code=503)
    return JSONResponse({"status": "ready"})


@app.get("/metrics", tags=["operations"])
def metrics() -> PlainTextResponse:
    """Prometheus-format metrics, ready for Task 4's observability stack
    (e.g. an ECS/CloudWatch or self-hosted Prometheus scrape target)."""
    return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)


app.include_router(tasks.router)
