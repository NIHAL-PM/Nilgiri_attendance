import math

class LocationService:
    @staticmethod
    def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """
        Calculates Great-Circle distance in meters between two GPS points using Haversine formula.
        """
        R = 6371000.0  # Earth's radius in meters

        phi1 = math.radians(lat1)
        phi2 = math.radians(lat2)
        delta_phi = math.radians(lat2 - lat1)
        delta_lambda = math.radians(lon2 - lon1)

        a = math.sin(delta_phi / 2.0) ** 2 + \
            math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0) ** 2

        c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
        distance = R * c

        return float(distance)

    @staticmethod
    def is_within_radius(distance_meters: float, radius_meters: float) -> bool:
        return distance_meters <= radius_meters
