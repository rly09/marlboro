import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), '..', 'cleancity.db')

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

def add_column(table, column, datatype):
    try:
        cursor.execute(f"ALTER TABLE {table} ADD COLUMN {column} {datatype}")
        print(f"Added {column} to {table}")
    except sqlite3.OperationalError as e:
        if "duplicate column name" in str(e).lower():
            print(f"Column {column} already exists in {table}")
        else:
            print(f"Error adding {column} to {table}: {e}")

add_column('users', 'trust_score', 'INTEGER DEFAULT 100')
add_column('users', 'total_cleanups', 'INTEGER DEFAULT 0')
add_column('reports', 'after_img', 'VARCHAR(255)')
add_column('reports', 'claimed_by_name', 'VARCHAR(50)')

conn.commit()
conn.close()
print("Database patch complete.")
