"""Application configuration.

All settings are sourced from environment variables so the same container
image can be promoted unchanged across dev, staging, and prod — the
twelve-factor "config in the environment" pattern the Terraform ECS task
definitions rely on.
"""
from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="APP_", case_sensitive=False)

    # Matches the `application_port` variable used by the ALB / security
    # group Terraform modules (default 8080).
    port: int = 8080

    environment: str = "local"
    log_level: str = "INFO"

    # Bumped on release; surfaced on /health and /version so a rollout can
    # be confirmed from outside the container.
    app_version: str = "0.1.0"


@lru_cache
def get_settings() -> Settings:
    return Settings()
