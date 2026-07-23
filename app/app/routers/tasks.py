from fastapi import APIRouter, HTTPException, status

from app.models import Task, TaskCreate, TaskUpdate
from app.store import task_store

router = APIRouter(prefix="/api/v1/tasks", tags=["tasks"])


@router.get("", response_model=list[Task])
def list_tasks() -> list[Task]:
    return task_store.list()


@router.post("", response_model=Task, status_code=status.HTTP_201_CREATED)
def create_task(payload: TaskCreate) -> Task:
    return task_store.create(payload)


@router.get("/{task_id}", response_model=Task)
def get_task(task_id: str) -> Task:
    task = task_store.get(task_id)
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@router.patch("/{task_id}", response_model=Task)
def update_task(task_id: str, payload: TaskUpdate) -> Task:
    task = task_store.update(task_id, payload)
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(task_id: str) -> None:
    if not task_store.delete(task_id):
        raise HTTPException(status_code=404, detail="Task not found")
