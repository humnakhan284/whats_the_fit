from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    GEMINI_API_KEY: str = ""
    GEMINI_MODEL: str = "gemini-2.5-flash"
    DATABASE_URL: str = "sqlite:///./whats_the_fit.db"
    ALLOWED_ORIGINS: str = "*"
    MAX_IMAGE_MB: int = 8
    STATIC_DIR: str = "static"
    STATIC_URL_PREFIX: str = "/static"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    @property
    def allowed_origins_list(self) -> list[str]:
        if self.ALLOWED_ORIGINS.strip() == "*":
            return ["*"]
        return [o.strip() for o in self.ALLOWED_ORIGINS.split(",") if o.strip()]

    @property
    def max_image_bytes(self) -> int:
        return self.MAX_IMAGE_MB * 1024 * 1024


@lru_cache
def get_settings() -> Settings:
    return Settings()
