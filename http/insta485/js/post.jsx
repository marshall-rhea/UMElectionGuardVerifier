import React from 'react';
import PropTypes from 'prop-types';
import Likes from './likes';
import Comments from './comments';
import moment from 'moment'

class Post extends React.Component {
  /* Display number of likes a like/unlike button for one post
   * Reference on forms https://facebook.github.io/react/docs/forms.html
   */

  constructor(props) {
    // Initialize mutable state
    super(props);
    this.state = {
      age: '',
      img_url: '',
      owner: '',
      owner_img_url: '',
      owner_show_url: '',
      post_show_url: '',
    };
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
          age: data.age,
          img_url: data.img_url,
          owner: data.owner,
          owner_img_url: data.owner_img_url,
          owner_show_url: data.owner_show_url,
          post_show_url: data.post_show_url,
        });
      })
      .catch((error) => console.log(error));
  };

  handleSubmit(event) {
    const { url } = this.props;
    event.preventDefault();
    var requestOptions;

    requestOptions = {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: {},
      credentials: 'same-origin'
    };

    fetch(url, requestOptions)
    .then((response) => {
      if (!response.ok) throw Error(response.statusText);
      if (this.state.logname_likes_this){
        this.setState({
          likes_count: this.state.likes_count - 1,
          logname_likes_this: this.state.logname_likes_this - 1,
          postid: this.state.postid,
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
    const { url } = this.props;
    const like_url = url + "likes/"
    const comments_url = url + "comments/"
    //const age_time = moment(this.state.age).fromNow();
    //console.log(age_time)
    // Render number of likes
    return (
      <div className="post">
        <div className="solid">
          <div className="topleft">
            <a href={this.state.owner_show_url}>
              <img src={this.state.owner_img_url} width="100" height="100" alt="Loading" />
                {this.state.owner}
            </a>
          </div>
          <div className="topright">
            <a href={this.state.post_show_url}>
              {moment(this.state.age).fromNow()}
            </a>
          </div>
          <Likes url = {like_url} img_url = {this.state.img_url} />
          <Comments url = {comments_url} />
        </div>
        <br />
      </div>
    );
  }
}

Post.propTypes = {
  url: PropTypes.string.isRequired,
};

export default Post;
