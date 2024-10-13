from app import db_pool
from app.route_index import Index
from dotenv import load_dotenv
from app.lib.db import fetch_one
from flask import render_template, redirect, url_for, session, request

load_dotenv()


@Index.route('/', methods=['GET', 'POST'])
def homepage():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        user = fetch_one(
            db_pool, 
            'SELECT * FROM users WHERE users.username = %s AND users.password = %s;', 
            (username, password)
        )

        if user:
            session['username'] = user['username']
            session['role_id'] = user['role_id']

            # role_id (1 = superadmin, 2 = admin, 3 = owner, 4 = employee)
            if user['role_id'] == 3:


            
                return redirect(url_for('Owner.dashboard'))
        else:
            return render_template('login.html', error='Invalid username or password')
    return render_template('login.html')

@Index.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('Index.homepage'))
