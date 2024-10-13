from .connection_pool import MySQLConnectionPool, Error

def execute_query(pool, query, params=None):
    connection = pool.get_connection()
    if connection:
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(query, params)
            connection.commit()
            return cursor
        except Error as e:
            print(f"Error: {e}")
            return None
        finally:
            cursor.close()
            connection.close()

def fetch_all(pool, query, params=None):
    connection = pool.get_connection()
    if connection:
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(query, params)
            result = cursor.fetchall()
            return result
        except Error as e:
            print(f"Error: {e}")
            return []
        finally:
            cursor.close()
            connection.close()
    return []

def fetch_one(pool, query, params=None):
    connection = pool.get_connection()
    if connection:
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(query, params)
            result = cursor.fetchone()
            return result
        except Error as e:
            print(f"Error: {e}")
            return None
        finally:
            cursor.close()
            connection.close()
    return None