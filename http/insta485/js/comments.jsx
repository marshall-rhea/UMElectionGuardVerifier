import React from 'react';
import PropTypes from 'prop-types';

class Comments extends React.Component {
  /* Display number of likes a like/unlike button for one post
   * Reference on forms https://facebook.github.io/react/docs/forms.html
   */

  constructor(props) {
    // Initialize mutable state
    super(props);
    this.state = {
      comments: [],
    };
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  componentDidMount() {
    // This line automatically assigns this.props.url to the const variable url
    const { url } = this.props;

    // Call REST API to get number of likes
    fetch(url, { credentials: 'same-origin' })
      .then((response) => {
        if (!response.ok) throw Error(response.statusText);
        return response.json();
      })
      .then((data) => {
        this.setState({
          comments: data.comments,
        });
      })
      .catch((error) => console.log(error));
  }

  handleSubmit(event) {
    if (event.which !== 13) return;
    const { url } = this.props;
    event.preventDefault();
    console.log(event.target.value);
    const input = `{"text" : "${event.target.value}"}`;
    const newComments = this.state.comments;
    const requestOptions = {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: input,
      credentials: 'same-origin',
    };

    fetch(url, requestOptions)
      .then((response) => {
        if (!response.ok) throw Error(response.statusText);
        return response.json();
      })
      .then((data) => {
        newComments.push(data);
        this.setState({
          comments: newComments,
        });
      })
      .catch((error) => console.log(error));
  };

  render() {
    const { url } = this.props;
    const postid = Number(url.split('/')[4]);
    console.log(url);
    console.log(postid);
    const comments = this.state.comments.map(
      (comment) => <p key={comment.commentid}>
      <a href={comment.owner_show_url}>{comment.owner}</a> 
      {comment.text}
    </p>);

    // Render number of likes
    return (
      <div className="comments">
        {comments}
        <form onSubmit={this.handleSubmit} action="/" method="post" encType="multipart/form-data" className="comment-form">
          <input type="hidden" name="postid" value={postid} />
          <input type="text" name="text" onKeyPress={this.handleSubmit} />
        </form>
      </div>
    );
  }
}

Comments.propTypes = {
  url: PropTypes.string.isRequired,
};

export default Comments;
