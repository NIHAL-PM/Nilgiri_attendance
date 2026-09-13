# VeriFace Event Attendance Platform

On-device facial biometric attendance system with client-side embedding generation and server-side Cosine Similarity matching (>= 0.75), with geofencing support and dark fintech aesthetic.

## Architecture

```
[ Student Device (Flutter) ]
     │ 
     ├── Camera Frame Capture
     ├── ML Kit Liveness Detection (Blink / Head tilt)
     └── TFLite Embedding Extraction (512-float Vector)
     │
     ▼ HTTPS / REST (JWT Auth)
[ Backend API (FastAPI) ]
     │
     ├── Token & Event Validation
     ├── Cosine Distance Calculation (Vector Match >= 0.75)
     └── Geofencing Boundary Engine (Haversine Distance <= radius)
     │
     ▼
[ Database: PostgreSQL (pgvector) / SQLite ]
```

## Quick Start: Backend Server

### 1. Run with Local Python
```powershell
cd backend
python -m pip install -r requirements.txt
$env:PYTHONPATH="."
python -m uvicorn app.main:app --reload --port 8000
```
Interactive Swagger API documentation will be available at:
`http://localhost:8000/docs`

### 2. Run with Docker Compose (PostgreSQL + pgvector)
```powershell
docker-compose up -d
```

### 3. Run Backend Test Suite
```powershell
$env:PYTHONPATH="backend"
python -m pytest backend/tests/test_biometrics.py -v
```

## Mobile Client (Flutter App)

Located in `client/`:
- **Screen 1**: Login Screen (`client/lib/screens/login_screen.dart`)
- **Screen 2**: Face Registration Screen (`client/lib/screens/face_registration_screen.dart`)
- **Screen 3**: Dashboard Screen (`client/lib/screens/dashboard_screen.dart`)
- **Screen 4**: Attendance Camera Screen (`client/lib/screens/attendance_camera_screen.dart`)
- **Screen 5**: Attendance Result Dialog (`client/lib/widgets/attendance_result_dialog.dart`)
