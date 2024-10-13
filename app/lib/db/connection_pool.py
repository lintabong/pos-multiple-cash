import mysql.connector
from mysql.connector import pooling, Error


class MySQLConnectionPool:
    def __init__(self, pool_name, pool_size, host, port, database, user, password):
        self.pool_name = pool_name
        self.pool_size = pool_size
        self.pool = mysql.connector.pooling.MySQLConnectionPool(
            pool_name=self.pool_name,
            pool_size=self.pool_size,
            pool_reset_session=True,
            host=host,
            port=port,
            database=database,
            user=user,
            password=password
        )

    def get_connection(self):
        try:
            connection = self.pool.get_connection()
            if connection.is_connected():
                return connection
        except Error as e:
            print(f"Error: {e}")
            return None
