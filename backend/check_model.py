
import google.generativeai as genai
from config import get_settings

settings = get_settings()
genai.configure(api_key=settings.GEMINI_API_KEY)

for model in genai.list_models():
    if "generateContent" in model.supported_generation_methods:
        print(model.name)        