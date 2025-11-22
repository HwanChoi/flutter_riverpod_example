from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from backend import crud, schemas, models
from backend.database import get_db
from backend.security import get_current_user

router = APIRouter(
    prefix="/boards/{board_id}/todos",
    tags=["todos"],
    responses={404: {"description": "Todo item not found"}},
)

@router.post("/", response_model=schemas.TodoItem)
def create_todo_item_for_board(
    board_id: int,
    todo_item: schemas.TodoItemCreate,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(get_current_user)
):
    db_board = crud.get_board(db, board_id=board_id)
    if db_board is None or db_board.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Board not found or not owned by user")
    return crud.create_board_todo_item(db=db, item=todo_item, board_id=board_id)

@router.put("/{todo_id}", response_model=schemas.TodoItem)
def update_todo_item_endpoint(
    board_id: int, # Included to ensure the todo belongs to the board
    todo_id: int,
    todo_item: schemas.TodoItemUpdate,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(get_current_user)
):
    db_item = crud.get_todo_item(db, item_id=todo_id)
    if db_item is None or db_item.board_id != board_id:
        raise HTTPException(status_code=404, detail="Todo item not found in this board")

    db_board = crud.get_board(db, board_id=board_id)
    if db_board is None or db_board.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to update this todo item")

    return crud.update_todo_item(db, item_id=todo_id, item=todo_item)

@router.delete("/{todo_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_todo_item_endpoint(
    board_id: int, # Included to ensure the todo belongs to the board
    todo_id: int,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(get_current_user)
):
    db_item = crud.get_todo_item(db, item_id=todo_id)
    if db_item is None or db_item.board_id != board_id:
        raise HTTPException(status_code=404, detail="Todo item not found in this board")
    
    db_board = crud.get_board(db, board_id=board_id)
    if db_board is None or db_board.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this todo item")

    crud.delete_todo_item(db, item_id=todo_id)
    return
