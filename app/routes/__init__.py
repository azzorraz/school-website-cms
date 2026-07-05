from flask import Blueprint

public_bp = Blueprint('public', __name__)
admin_bp = Blueprint('admin', __name__)

from app.routes import public_routes, admin_routes
