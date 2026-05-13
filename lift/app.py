# app.py
# Project: Lift — Hill Valley Tech
# Purpose: Main Flask application entry point. Exposes a REST API on port 8080.
# Variables used:
#   DATABASE_URL — PostgreSQL connection string (consumed by lib/storage.py).
#   API_KEY      — Bearer token for request authentication (consumed by lib/auth.py).
# Production start command:
#   gunicorn --bind 0.0.0.0:8080 --workers 4 app:app

import os
from flask import Flask, jsonify
from dotenv import load_dotenv

from lib.auth import require_api_key
from lib.storage import fetch_all

load_dotenv()

app = Flask(__name__)


@app.route("/health", methods=["GET"])
def health():
    """Public liveness probe — used by Kubernetes readiness/liveness checks."""
    return jsonify({"status": "ok"}), 200


@app.route("/items", methods=["GET"])
@require_api_key
def list_items():
    """Return all items from the database. Requires valid API_KEY."""
    rows = fetch_all("SELECT * FROM items ORDER BY id;")
    return jsonify({"items": rows}), 200


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
