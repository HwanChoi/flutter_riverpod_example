from pydantic import BaseModel
from typing import List, Optional

class UserBase(BaseModel):
    username: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    is_active: bool

    class Config:
        orm_mode = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TodoItemBase(BaseModel):
    description: str
    completed: bool = False

class TodoItemCreate(TodoItemBase):
    pass

class TodoItemUpdate(BaseModel):
    description: Optional[str] = None
    completed: Optional[bool] = None

class TodoItem(TodoItemBase):
    id: int
    board_id: int

    class Config:
        orm_mode = True

class BoardBase(BaseModel):
    title: str

class BoardCreate(BoardBase):
    pass

class Board(BoardBase):
    id: int
    owner_id: int
    todos: List[TodoItem] = [] # Uncommented after TodoItem is defined

    class Config:
        orm_mode = True