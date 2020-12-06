"""REST API for likes."""
import json
import flask
import insta485


@insta485.app.route(
    '/api/v1/p/<int:postid_url_slug>/likes/',
    methods=["GET", "POST"])
def get_likes(postid_url_slug):
    """Display like route."""
    if flask.request.method == "GET":
        if "username" in flask.session:
            connection = insta485.model.get_db()
            cur = connection.execute(
                "SELECT * FROM posts "
                "WHERE postid = {}".format(postid_url_slug)
                )
            single_post = cur.fetchone()
            if single_post is None:
                error_msg = {
                    "message": "Forbidden",
                    "status_code": 404
                    }
                return flask.jsonify(**error_msg), 404
            cur = connection.execute(
                "SELECT COUNT(*) FROM likes "
                "WHERE postid = '{}'".format(postid_url_slug)
                )
            likes = cur.fetchone()
            cur = connection.execute(
                "SELECT 1 WHERE EXISTS ( "
                "SELECT * FROM likes WHERE "
                "owner = '{}' AND postid = '{}')".format(
                    flask.session["username"], postid_url_slug)
                )
            likebylog = len(cur.fetchall())
            ret_val = {
                "logname_likes_this": likebylog,
                "likes_count": likes['COUNT(*)'],
                "postid": postid_url_slug,
                "url": "/api/v1/p/{}/likes/".format(postid_url_slug)
                }
            return flask.jsonify(**ret_val)
        error_msg = {
            "message": "Forbidden",
            "status_code": 403
            }
        return flask.jsonify(**error_msg), 403

    if "username" in flask.session:
        connection = insta485.model.get_db()
        cur = connection.execute(
            "SELECT * from likes WHERE "
            "owner = '{}' AND postid = '{}'".format(
                flask.session["username"], postid_url_slug)
            )
        if_exist = cur.fetchall()
        if len(if_exist) > 0:
            ret_val = {
                "logname": flask.session['username'],
                "message": "Conflict",
                "postid": postid_url_slug,
                "status_code": 409
                }
            return flask.jsonify(**ret_val), 409

        cur = connection.execute(
            "INSERT INTO likes(owner, postid) "
            "VALUES ('{}', '{}');".format(
                flask.session["username"], postid_url_slug)
            )
        ret_val = {
            "logname": flask.session['username'],
            "postid": postid_url_slug
            }
        return flask.jsonify(**ret_val), 201
    error_msg = {
        "message": "Forbidden",
        "status_code": 403
        }
    return flask.jsonify(**error_msg), 403


@insta485.app.route(
    '/api/v1/p/<int:postid_url_slug>/likes/', methods=["DELETE"])
def delete_likes(postid_url_slug):
    """Display delete route."""
    if "username" in flask.session:
        connection = insta485.model.get_db()
        connection.execute(
            "DELETE FROM likes "
            "WHERE owner = '{}' AND postid = '{}'".format(
                flask.session["username"], postid_url_slug)
            )
        return '', 204
    error_msg = {
        "message": "Forbidden",
        "status_code": 403
        }
    return flask.jsonify(**error_msg), 403


@insta485.app.route('/api/v1/', methods=["GET"])
def get_resource():
    """Display resource route."""
    item = {
        "posts": "/api/v1/p/",
        "url": "/api/v1/"
        }
    return item


@insta485.app.route('/api/v1/p/', methods=["GET"])
def get_tenpost():
    """Display posts route."""
    if "username" in flask.session:
        connection = insta485.model.get_db()
        cur = connection.execute(
            "SELECT * FROM posts "
            "WHERE owner = '{}' OR "
            "EXISTS (SELECT * FROM following WHERE "
            "username1 = '{}' AND username2 = owner) "
            "ORDER BY postid DESC".format(
                flask.session["username"], flask.session["username"]
                )
            )
        posts = cur.fetchall()
        ret_post = []
        size = flask.request.args.get('size', default=10, type=int)
        page = flask.request.args.get('page', default=0, type=int)
        next_page = ""
        error_msg = {
            "message": "Bad Request",
            "status_code": 400
        }
        if size < 0:
            return flask.jsonify(**error_msg)
        if page < 0:
            return flask.jsonify(**error_msg)
        if len(posts) > (size * (page + 1)):
            next_page = "/api/v1/p/?size={}&page={}".format(size, page + 1)
            posts = posts[page * size: (page + 1) * size]
        else:
            posts = posts[-(len(posts) - page * size):]

        for single_post in posts:
            new_post = {
                "postid": single_post['postid'],
                "url": "/api/v1/p/{}/".format(single_post['postid'])
            }
            ret_post.append(new_post)
        ret_val = {
            "next": next_page,
            "results": ret_post,
            "url": "/api/v1/p/"
            }
        return flask.jsonify(**ret_val)
    error_msg = {
        "message": "Forbidden",
        "status_code": 403
        }
    return flask.jsonify(**error_msg), 403


@insta485.app.route('/api/v1/p/<int:postid_url_slug>/', methods=["GET"])
def get_post(postid_url_slug):
    """Display post route."""
    if "username" in flask.session:
        connection = insta485.model.get_db()
        cur = connection.execute(
            "SELECT * FROM posts "
            "WHERE postid = {}".format(postid_url_slug)
            )
        single_post = cur.fetchone()
        if single_post is None:
            error_msg = {
                "message": "Forbidden",
                "status_code": 404
                }
            return flask.jsonify(**error_msg), 404
        cur = connection.execute(
            "SELECT * FROM users "
            "WHERE username = '{}'".format(single_post['owner'])
            )
        post_owner = cur.fetchone()
        print(post_owner)
        ret_val = {
            "age": single_post['created'],
            "img_url": "/uploads/" + single_post['filename'],
            "owner": single_post['owner'],
            "owner_img_url": "/uploads/" + post_owner['filename'],
            "owner_show_url": "/u/{}/".format(post_owner['username']),
            "post_show_url": "/p/{}/".format(single_post['postid']),
            "url": "/api/v1/p/{}/".format(single_post['postid'])
            }
        return flask.jsonify(**ret_val)
    error_msg = {
        "message": "Forbidden",
        "status_code": 403
        }
    return flask.jsonify(**error_msg), 403


@insta485.app.route(
    '/api/v1/p/<int:postid_url_slug>/comments/', methods=["GET", "POST"])
def get_comment(postid_url_slug):
    """Display comment route."""
    if flask.request.method == "GET":
        if "username" in flask.session:
            connection = insta485.model.get_db()
            cur = connection.execute(
                "SELECT * FROM posts "
                "WHERE postid = {}".format(postid_url_slug)
                )
            single_post = cur.fetchone()
            if single_post is None:
                error_msg = {
                    "message": "Forbidden",
                    "status_code": 404
                    }
                return flask.jsonify(**error_msg), 404
            cur = connection.execute(
                "SELECT * FROM comments "
                "WHERE postid = {} "
                "ORDER BY commentid ASC".format(postid_url_slug)
                )
            comments = cur.fetchall()
            ret_val = []
            for comment in comments:
                new_comment = {
                    "commentid": comment['commentid'],
                    "owner": comment['owner'],
                    "owner_show_url": "/u/{}/".format(comment['owner']),
                    "postid": comment['postid'],
                    "text": comment['text']
                    }
                ret_val.append(new_comment)
            ret_val = {
                "comments": ret_val,
                "url": "/api/v1/p/{}/comments/".format(postid_url_slug)

            }
            return flask.jsonify(**ret_val)
        error_msg = {
            "message": "Forbidden",
            "status_code": 403
            }
        return flask.jsonify(**error_msg), 403

    if "username" in flask.session:
        connection = insta485.model.get_db()
        cur = connection.execute(
            "SELECT * FROM posts "
            "WHERE postid = {}".format(postid_url_slug)
            )
        single_post = cur.fetchone()
        if single_post is None:
            error_msg = {
                "message": "Forbidden",
                "status_code": 404
                }
            return flask.jsonify(**error_msg), 404
        data = json.loads(flask.request.data.decode('utf-8'))
        cur = connection.execute(
            "SELECT COUNT(*) FROM comments "
            )
        max_num_1 = cur.fetchone()["COUNT(*)"] + 1
        cur = connection.execute(
            "INSERT INTO comments(commentid, owner, postid, text) "
            "VALUES ('{}', '{}', '{}', '{}');".format(
                max_num_1, flask.session["username"],
                postid_url_slug,
                data['text']
                )
            )
        cur = connection.execute(
            "SELECT last_insert_rowid()"
            )
        last_row_id = cur.fetchone()
        ret_val = {
            "commentid": last_row_id['last_insert_rowid()'],
            "owner": flask.session['username'],
            "owner_show_url": "/u/{}/".format(flask.session['username']),
            "postid": postid_url_slug,
            "text": data['text']
        }
        return flask.jsonify(**ret_val), 201
    error_msg = {
        "message": "Forbidden",
        "status_code": 403
        }
    return flask.jsonify(**error_msg), 403
