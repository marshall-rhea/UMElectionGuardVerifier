"""
Insta485 index (main) view.

URLs include:
/
"""
import uuid
import hashlib
import os
import shutil
import tempfile
import arrow
import flask
import insta485

@insta485.app.route('/', methods=["POST", "GET"])
def show_index():
    """Display / route."""
    if flask.request.method == "POST":
        # Upload format ??? Fetch content
        return flask.redirect(flask.url_for("verified"))

    return flask.render_template("upload.html")



@insta485.app.route('/verified/', methods=["POST", "GET"])
def verified():
    """Display /verified/ route."""
    # Insert verifier API here and pass result to context
    context = {}

    return flask.render_template("verify.html", **context)
