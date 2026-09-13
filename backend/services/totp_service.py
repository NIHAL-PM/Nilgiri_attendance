import pyotp

class TOTPService:
    @staticmethod
    def generate_secret() -> str:
        """Generates a random 32-character base32 secret for Google Authenticator"""
        return pyotp.random_base32()

    @staticmethod
    def get_provisioning_uri(secret: str, email: str, issuer_name: str = "PulseAttend") -> str:
        """Returns the otpauth:// URI to generate QR codes for authenticator apps"""
        totp = pyotp.TOTP(secret)
        return totp.provisioning_uri(name=email, issuer_name=issuer_name)

    @staticmethod
    def verify_totp(secret: str, code: str) -> bool:
        """Verifies a 6-digit TOTP code against the secret (allowing 30s window drift)"""
        if not secret or not code:
            return False
        totp = pyotp.TOTP(secret)
        return totp.verify(code, valid_window=1)
