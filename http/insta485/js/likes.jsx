import React from 'react';
import PropTypes from 'prop-types';

class Likes extends React.Component {
  /* Display number of likes a like/unlike button for one post
   * Reference on forms https://facebook.github.io/react/docs/forms.html
   */

  constructor(props) {
    // Initialize mutable state
    super(props);
    this.state = { 
      likes_count: 0,
      logname_likes_this: 0,
      postid: 0,
    };
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleDoubleClick = this.handleDoubleClick.bind(this);
  }

  handleDoubleClick(event) {
    // This line automatically assigns this.props.url to the const variable url
    event.preventDefault();
    if(this.state.logname_likes_this){
      return;
    }
    const  url  = this.props.url;
    var requestOptions = {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: {},
      credentials: 'same-origin'
    };
    // Call REST API to get number of likes
    fetch(url, requestOptions)
    .then((response) => {
      if (!response.ok) throw Error(response.statusText);
      if (!this.state.logname_likes_this){
        this.setState({
          likes_count: this.state.likes_count + 1,
          logname_likes_this: this.state.logname_likes_this + 1,
          postid: this.state.postid
        });
      }
    })
    .catch((error) => console.log(error));
  }

  componentDidMount() {
    // This line automatically assigns this.props.url to the const variable url
    const  url  = this.props.url;

    // Call REST API to get number of likes
    fetch(url, { credentials: 'same-origin' })
      .then((response) => {
        if (!response.ok) throw Error(response.statusText);
        return response.json();
      })
      .then((data) => {
        this.setState({
          likes_count: data.likes_count,
          logname_likes_this: data.logname_likes_this,
          postid: data.postid
        });
      })
      .catch((error) => console.log(error));
  }

  handleSubmit(event) {
    const  url  = this.props.url;
    event.preventDefault();
    var requestOptions;
    if (this.state.logname_likes_this) {
    requestOptions = {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' },
      body: {},
      credentials: 'same-origin',
    };
    }else{
    requestOptions = {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: {},
      credentials: 'same-origin'
    };
  }
    fetch(url, requestOptions)
    .then((response) => {
      if (!response.ok) throw Error(response.statusText);
      if (this.state.logname_likes_this){
        this.setState({
          likes_count: this.state.likes_count - 1,
          logname_likes_this: this.state.logname_likes_this - 1,
          postid: this.state.postid
        });
      } else{
        this.setState({
          likes_count: this.state.likes_count + 1,
          logname_likes_this: this.state.logname_likes_this + 1,
          postid: this.state.postid
        });
      }
    })

    .catch((error) => console.log(error));
  };

  render() {
    // This line automatically assigns this.state.numLikes to the const variable numLikes
    const numLikes = this.state.likes_count;
    const isLiked = this.state.logname_likes_this;
    const postid = this.state.postid;
    // Render number of likes
    return (
      <div className="likes">
        <img src={this.props.img_url} alt="Loading" onDoubleClick={this.handleDoubleClick} />
        <p>
        {numLikes}
        {' '}
        like
        {numLikes !== 1 ? 's' : ''}
        </p>
        {isLiked ? (
        <button onClick={this.handleSubmit} className="like-unlike-button">
        unlike
        </button>
      ) : (
        <button onClick={this.handleSubmit} className="like-unlike-button">
        like
        </button>
      )}
      </div>
    );
  }
}

Likes.propTypes = {
  url: PropTypes.string.isRequired,
};

export default Likes;
