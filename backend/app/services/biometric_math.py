import math
import numpy as np
from typing import List, Tuple

def compute_cosine_similarity(vector_a: List[float], vector_b: List[float]) -> float:
    """
    Computes the Cosine Similarity between two floating point vectors:
    Similarity = (A . B) / (||A|| * ||B||)
    Returns float in range [-1.0, 1.0]
    """
    a = np.array(vector_a, dtype=np.float32)
    b = np.array(vector_b, dtype=np.float32)
    
    norm_a = np.linalg.norm(a)
    norm_b = np.linalg.norm(b)
    
    if norm_a == 0.0 or norm_b == 0.0:
        return 0.0
    
    similarity = float(np.dot(a, b) / (norm_a * norm_b))
    return float(np.clip(similarity, -1.0, 1.0))

def haversine_distance_meters(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculates great-circle distance between two GPS coordinates in meters.
    """
    R = 6371000.0  # Earth radius in meters
    
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)
    
    a = math.sin(delta_phi / 2.0)**2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0)**2
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    
    return R * c
