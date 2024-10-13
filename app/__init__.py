import os
import mysql.connector
from flask import Flask, session
from flask_session import Session
from flask_cors import CORS
from dotenv import load_dotenv

from app.lib.db import MySQLConnectionPool

load_dotenv()

db_pool = MySQLConnectionPool(
    pool_name=os.getenv('MYSQL_POOL_NAME'),
    pool_size=int(os.getenv('MYSQL_POOL_SIZE', 5)),
    host=os.getenv('MYSQL_HOST'),
    port=int(os.getenv('MYSQL_PORT', 3306)),
    database=os.getenv('MYSQL_DATABASE_NAME'),
    user=os.getenv('MYSQL_USERNAME'),
    password=os.getenv('MYSQL_PASSWORD')
)

def create_app():
    app = Flask(__name__)

    app.config['SESSION_PERMANENT'] = False
    app.config['SESSION_TYPE'] = 'filesystem'
    Session(app)
    CORS(app)

    from app.route_index import Index
    app.register_blueprint(Index)

    from app.route_owner import Owner
    app.register_blueprint(Owner)

    return app
