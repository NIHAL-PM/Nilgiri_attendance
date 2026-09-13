import numpy as np
from config import settings

class FaceService:
    @staticmethod
    def calculate_cosine_similarity(vec1: list[float], vec2: list[float]) -> float:
        """
        Calculates cosine similarity between two 512-dimensional face vectors.
        Returns a float between -1.0 and 1.0 (where 1.0 is exact match).
        """
        a = np.array(vec1, dtype=np.float32)
        b = np.array(vec2, dtype=np.float32)

        norm_a = np.linalg.norm(a)
        norm_b = np.linalg.norm(b)

        if norm_a == 0 or norm_b == 0:
            return 0.0

        similarity = float(np.dot(a, b) / (norm_a * norm_b))
        return max(0.0, min(1.0, similarity))

    @staticmethod
    def passes_threshold(score: float, custom_threshold: float | None = None) -> bool:
        thresh = custom_threshold if custom_threshold is not None else settings.SIMILARITY_THRESHOLD
        return score >= thresh
