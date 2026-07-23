"""A minimal thread-safe in-memory store.

Deliberately not a database: this sample app's job is to demonstrate the
container contract (health checks, config, logging, graceful shutdown),
not to be a real persistence layer. Swapping this for Postgres (the `private
db subnet` tier already provisioned in Terraform) would be the natural next
step for a real service.
"""
import threading
from datetime import datetime, timezone

from app.models import Task, TaskCreate, TaskUpdate


class TaskStore:
    def __init__(self) -> None:
        self._tasks: dict[str, Task] = {}
        self._lock = threading.Lock()

    def list(self) -> list[Task]:
        with self._lock:
            return list(self._tasks.values())

    def get(self, task_id: str) -> Task | None:
        with self._lock:
            return self._tasks.get(task_id)

    def create(self, payload: TaskCreate) -> Task:
        task = Task(title=payload.title, description=payload.description)
        with self._lock:
            self._tasks[task.id] = task
        return task

    def update(self, task_id: str, payload: TaskUpdate) -> Task | None:
        with self._lock:
            task = self._tasks.get(task_id)
            if task is None:
                return None

            data = task.model_dump()
            updates = payload.model_dump(exclude_unset=True)
            data.update(updates)
            data["updated_at"] = datetime.now(timezone.utc)

            updated = Task(**data)
            self._tasks[task_id] = updated
            return updated

    def delete(self, task_id: str) -> bool:
        with self._lock:
            return self._tasks.pop(task_id, None) is not None


task_store = TaskStore()
