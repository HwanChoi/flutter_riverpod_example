from fastapi import FastAPI
from backend.database import Base, engine
from backend.routers import auth, boards, todos

# Create all database tables
Base.metadata.create_all(bind=engine)

app = FastAPI()

app.include_router(auth.router)
app.include_router(boards.router)
app.include_router(todos.router)

@app.get("/")
async def root():
    return {"message": "Welcome to TodoFlow API"}
