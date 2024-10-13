from flask import Blueprint

Owner = Blueprint('owner', __name__)

from app.route_owner import dashboard
