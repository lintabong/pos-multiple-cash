from app import db_pool
from app.route_owner import Owner
from dotenv import load_dotenv
from app.lib.db import fetch_one
from flask import render_template, request, redirect, url_for, session

load_dotenv()


@Owner.route('/owner/dashboard')
def dashboard():
    return render_template('dashboard.html')

@Owner.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('admin.login'))
