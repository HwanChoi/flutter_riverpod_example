from sqlalchemy.orm import Session
from backend import models, schemas
from backend.security import get_password_hash, verify_password

def get_user(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id).first()

def get_user_by_username(db: Session, username: str):
    return db.query(models.User).filter(models.User.username == username).first()

def create_user(db: Session, user: schemas.UserCreate):
    hashed_password = get_password_hash(user.password)
    db_user = models.User(username=user.username, hashed_password=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def create_user_board(db: Session, board: schemas.BoardCreate, user_id: int):
    db_board = models.Board(**board.dict(), owner_id=user_id)
    db.add(db_board)
    db.commit()
    db.refresh(db_board)
    return db_board

def get_boards(db: Session, user_id: int, skip: int = 0, limit: int = 100):
    return db.query(models.Board).filter(models.Board.owner_id == user_id).offset(skip).limit(limit).all()

def get_board(db: Session, board_id: int):
    return db.query(models.Board).filter(models.Board.id == board_id).first()

def update_board_title(db: Session, board_id: int, title: str):
    db_board = db.query(models.Board).filter(models.Board.id == board_id).first()
    if db_board:
        db_board.title = title
        db.commit()
        db.refresh(db_board)
    return db_board

def delete_board(db: Session, board_id: int):
    db_board = db.query(models.Board).filter(models.Board.id == board_id).first()
    if db_board:
        db.delete(db_board)
        db.commit()
    return db_board

def create_board_todo_item(db: Session, item: schemas.TodoItemCreate, board_id: int):
    db_item = models.TodoItem(**item.dict(), board_id=board_id)
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item

def get_todo_item(db: Session, item_id: int):
    return db.query(models.TodoItem).filter(models.TodoItem.id == item_id).first()

def update_todo_item(db: Session, item_id: int, item: schemas.TodoItemUpdate):
    db_item = db.query(models.TodoItem).filter(models.TodoItem.id == item_id).first()
    if db_item:
        if item.description is not None:
            db_item.description = item.description
        if item.completed is not None:
            db_item.completed = item.completed
        db.commit()
        db.refresh(db_item)
    return db_item

def delete_todo_item(db: Session, item_id: int):
    db_item = db.query(models.TodoItem).filter(models.TodoItem.id == item_id).first()
    if db_item:
        db.delete(db_item)
        db.commit()
    return db_item
