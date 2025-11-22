from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from backend import crud, schemas, models
from backend.database import get_db
from backend.security import get_current_user

router = APIRouter(
    prefix="/boards",
    tags=["boards"],
    responses={404: {"description": "Board not found"}},
)

@router.post("/", response_model=schemas.Board)
def create_board_for_user(
    board: schemas.BoardCreate,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(get_current_user)
):
    return crud.create_user_board(db=db, board=board, user_id=current_user.id)

@router.get("/", response_model=List[schemas.Board])
def read_boards(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(get_current_user)
):
    boards = crud.get_boards(db, user_id=current_user.id, skip=skip, limit=limit)
    return boards

@router.get("/{board_id}", response_model=schemas.Board)
def read_board(
    board_id: int,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(get_current_user)
):
    board = crud.get_board(db, board_id=board_id)
    if board is None or board.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Board not found")
    return board

@router.put("/{board_id}", response_model=schemas.Board)
def update_board(
    board_id: int,
    board: schemas.BoardCreate, # Reusing BoardCreate schema for title update
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(get_current_user)
):
    db_board = crud.get_board(db, board_id=board_id)
    if db_board is None or db_board.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Board not found or not owned by user")
    return crud.update_board_title(db, board_id=board_id, title=board.title)

@router.delete("/{board_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_board_endpoint(
    board_id: int,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(get_current_user)
):
    db_board = crud.get_board(db, board_id=board_id)
    if db_board is None or db_board.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Board not found or not owned by user")
    crud.delete_board(db, board_id=board_id)
    return {"ok": True}
