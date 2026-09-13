from routers.auth import router as auth_router
from routers.users import router as users_router
from routers.events import router as events_router
from routers.attendance import router as attendance_router

__all__ = ["auth_router", "users_router", "events_router", "attendance_router"]
