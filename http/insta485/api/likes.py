"""REST API for likes."""
import json
import flask
import insta485

@insta485.app.route('/api/v1/', methods=["GET"])
def get_resource():
    """Display resource route."""
    item = {
        "posts": "/api/v1/p/",
        "url": "/api/v1/"
        }
    return item
