import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from config import get_settings
from database import Base, engine

from routes.assistants import ASSISTANT_ROUTERS
from routes.history import router as history_router
from routes.looks import router as looks_router
from routes.wardrobe import router as wardrobe_router
from routes.outfit_generator import router as outfit_router
from routes.color_palette import router as color_palette_router
from routes.weather import router as weather_router
from routes.trends import router as trends_router
from routes.daily_tips import router as daily_tips_router

settings = get_settings()

app = FastAPI(
    title="What's The Fit? API",
    version="2.0.0",
    description="AI Fashion Assistant Backend",
)


@app.on_event("startup")
def startup():
    Base.metadata.create_all(bind=engine)
    os.makedirs(settings.STATIC_DIR, exist_ok=True)


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def home():
    return {"message": "Welcome to What's The Fit API"}


@app.get("/health")
def health():
    return {"status": "healthy"}


for router in ASSISTANT_ROUTERS:
    app.include_router(router)

app.include_router(history_router)
app.include_router(looks_router)
app.include_router(wardrobe_router)
app.include_router(outfit_router)
app.include_router(color_palette_router)
app.include_router(weather_router)
app.include_router(trends_router)
app.include_router(daily_tips_router)

app.mount(
    settings.STATIC_URL_PREFIX,
    StaticFiles(directory=settings.STATIC_DIR),
    name="static",
)