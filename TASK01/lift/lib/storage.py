# lib/storage.py
# Project: Lift — Hill Valley Tech
# Purpose: PostgreSQL connection and basic query helpers.
# Variables used:
#   DATABASE_URL — full connection string (postgres://user:pass@host:port/db),
#                  injected at runtime via environment variable.

import os
import psycopg2
from psycopg2.extras import RealDictCursor

DATABASE_URL = os.environ.get("DATABASE_URL")


def get_connection():
    """Open and return a new database connection."""
    return psycopg2.connect(DATABASE_URL, cursor_factory=RealDictCursor)


def fetch_all(query: str, params: tuple = ()):
    """Execute a SELECT query and return all rows as a list of dicts."""
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(query, params)
            return cur.fetchall()


def execute(query: str, params: tuple = ()):
    """Execute an INSERT/UPDATE/DELETE query and commit."""
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(query, params)
        conn.commit()
