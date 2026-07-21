# What's The Fit  - 

A full-stack, modular AI-driven fashion and style assistant designed to provide personalized outfit recommendations, color palette analysis, and intelligent wardrobe management.

##  Key Features

- **Color Palette Analyzer:** Upload images to extract and analyze personal seasonal color palettes.
- **Smart Outfit Generator:** AI-powered suggestions tailored for different occasions, weather, and styles.
- **Wardrobe Manager:** Organize, categorize, and track clothing items seamlessly.
- **AI Chat Assistant:** Interactive style companion for real-time fashion and styling advice.
- **Trends & Daily Tips:** Stay updated with dynamic fashion trends and curated daily styling tips.
- **History Tracking:** Save and manage past styling results and favorite looks.

## 🛠️ Tech Stack

### Frontend (Mobile App)
- **Framework:** Flutter (Dart)
- **Architecture:** Feature-based modular structure
- **State Management:** StatefulWidget & Service pattern

### Backend (API Server)
- **Framework:** Python (FastAPI / Flask)
- **AI Integration:** Google Gemini API
- **Database:** SQLite / Local Storage

---

##  Project Structure

```text
whats_the_fit/
├── Frontend/         # Flutter mobile application
│   ├── lib/          # App screens, widgets, models, and services
│   └── pubspec.yaml  # Flutter dependencies
├── backend/          # Python backend server
│   ├── routes/       # API endpoints (color palette, wardrobe, trends, etc.)
│   ├── services/     # Business logic & Gemini client integration
│   ├── main.py       # FastAPI application entry point
│   └── requirements.txt
└── .gitignore        # Ignored confidential/system files
