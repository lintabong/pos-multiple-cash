from flask import Blueprint

Index = Blueprint('index', __name__)

from app.route_index import index
