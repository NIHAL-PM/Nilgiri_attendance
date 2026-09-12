import pytest
import numpy as np
from fastapi.testclient import TestClient
from app.main import app, init_db
from app.services.biometric_math import compute_cosine_similarity, haversine_distance_meters

# Initialize in-memory/sqlite database
init_db()
client = TestClient(app)

def generate_random_unit_vector(dim=512, seed=42):
    np.random.seed(seed)
    vec = np.random.randn(dim).astype(np.float32)
    return (vec / np.linalg.norm(vec)).tolist()

def test_cosine_similarity_math():
    v1 = generate_random_unit_vector(512, seed=1)
    # Identical vector should yield 1.0
    sim_identical = compute_cosine_similarity(v1, v1)
    assert pytest.approx(sim_identical, 0.001) == 1.0

    # Slight perturbation (0.01 std on 512 dimensions)
    np.random.seed(42)
    v_near = (np.array(v1) + np.random.normal(0, 0.01, 512).astype(np.float32)).tolist()
    sim_near = compute_cosine_similarity(v1, v_near)
    assert sim_near > 0.85

    # Completely different seed vectors in 512 dimensions yield near zero similarity (< 0.20)
    v2 = generate_random_unit_vector(512, seed=99)
    sim_different = compute_cosine_similarity(v1, v2)
    assert abs(sim_different) < 0.20

def test_haversine_distance():
    # Distance between two nearby points in Nilgiri/Kerala
    dist = haversine_distance_meters(10.8505, 76.2711, 10.8506, 76.2712)
    assert 10.0 < dist < 30.0

def test_full_attendance_lifecycle():
    # 1. Login with seeded demo student
    login_res = client.post("/api/v1/auth/login", json={
        "email_or_id": "student@nilgiri.edu",
        "password": "Student@123"
    })
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Register facial master embedding (512-float array)
    master_vec = generate_random_unit_vector(512, seed=101)
    reg_res = client.post("/api/v1/biometrics/register", json={"embedding": master_vec}, headers=headers)
    assert reg_res.status_code == 200
    assert reg_res.json()["is_face_registered"] is True

    # 3. Create a fresh geofenced event for testing
    evt_create = client.post("/api/v1/events/", json={
        "name": "Biometrics Lab Keynote",
        "code": "EVT-BIO-101",
        "location_name": "Auditorium A",
        "latitude": 10.8505,
        "longitude": 76.2711,
        "radius_meters": 100.0,
        "is_geofenced": True,
        "start_time": "2026-09-12T10:00:00Z",
        "end_time": "2026-09-12T20:00:00Z"
    }, headers=headers)
    assert evt_create.status_code == 201
    event_id = evt_create.json()["id"]

    # 4. Geofence violation test FIRST (User is ~11km away at 10.9500 -> Expect 403 Out of event boundary)
    np.random.seed(123)
    matching_vec = (np.array(master_vec) + np.random.normal(0, 0.01, 512).astype(np.float32)).tolist()
    far_verify = client.post("/api/v1/attendance/verify", json={
        "event_id": event_id,
        "embedding": matching_vec,
        "timestamp": 1774000000,
        "latitude": 10.9500,
        "longitude": 76.2711
    }, headers=headers)
    assert far_verify.status_code == 403
    assert "boundary" in far_verify.json()["detail"].lower()

    # 5. Verify attendance with a matching face vector within geofence boundary (cosine similarity >= 0.75)
    verify_res = client.post("/api/v1/attendance/verify", json={
        "event_id": event_id,
        "embedding": matching_vec,
        "timestamp": 1774000000,
        "latitude": 10.8505,
        "longitude": 76.2711
    }, headers=headers)
    assert verify_res.status_code == 200
    data = verify_res.json()
    assert data["status"] == "verified"
    assert data["similarity_score"] >= 0.75

    # 6. Unmatched face test (imposter face -> Expect 403 Face does not match)
    client.post("/api/v1/auth/register-student", json={
        "email": "imposter@nilgiri.edu",
        "student_id": "STU_8888",
        "full_name": "Fake Imposter",
        "password": "Password@123"
    })
    imposter_login = client.post("/api/v1/auth/login", json={
        "email_or_id": "imposter@nilgiri.edu",
        "password": "Password@123"
    })
    imposter_token = imposter_login.json()["access_token"]
    imposter_headers = {"Authorization": f"Bearer {imposter_token}"}
    
    imposter_vec = generate_random_unit_vector(512, seed=999)
    client.post("/api/v1/biometrics/register", json={"embedding": imposter_vec}, headers=imposter_headers)

    # Event for imposter check
    evt2 = client.post("/api/v1/events/", json={
        "name": "Robotics Lab Check-in",
        "code": "EVT-ROBO-99",
        "location_name": "Robotics Lab",
        "latitude": 10.8505,
        "longitude": 76.2711,
        "radius_meters": 100.0,
        "is_geofenced": False,
        "start_time": "2026-09-12T10:00:00Z",
        "end_time": "2026-09-12T18:00:00Z"
    }, headers=headers).json()

    imposter_verify = client.post("/api/v1/attendance/verify", json={
        "event_id": evt2["id"],
        "embedding": master_vec, # Submitting Alex's face while logged in as imposter
        "timestamp": 1774000000
    }, headers=imposter_headers)
    assert imposter_verify.status_code == 403
    assert "Verification Failed" in imposter_verify.json()["detail"]
