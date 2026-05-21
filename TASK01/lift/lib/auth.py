a# lib/auth.py
# Project: Lift — Hill Valley Tech
# Purpose: API key authentication middleware.
# Variables used:
#   API_KEY — expected bearer token, injected at runtime via environment variable.

import os
from functools import wraps
from flask import request, jsonify

API_KEY = os.environ.get("API_KEY")


def require_api_key(f):
    """Decorator that validates the Bearer token on incoming requests."""
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer ") or auth_header[7:] != API_KEY:
            return jsonify({"error": "Unauthorized"}), 401
        return f(*args, **kwargs)
    return decorated
