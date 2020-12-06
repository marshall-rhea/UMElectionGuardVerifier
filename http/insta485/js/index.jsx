import React from 'react';
import PropTypes from 'prop-types';
import Posts from './posts';

class Index extends React.Component {
  /* Display number of likes a like/unlike button for one post
   * Reference on forms https://facebook.github.io/react/docs/forms.html
   */

  constructor(props) {
    // Initialize mutable state
    super(props);
    this.state = { posts: "" };
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
          posts: data.posts,
        });
      })
      .catch((error) => console.log(error));
  }

  render() {
    // This line automatically assigns this.state.numLikes to the const variable numLikes

    const post_url = this.state.posts;
    console.log(this.state)
    console.log(post_url)
    if (post_url == ''){
      return null;
    }
    // Render number of likes
    return (
      <div className="index">
        <Posts url={post_url} />
      </div>
    );
  }
}

Index.propTypes = {
  url: PropTypes.string.isRequired,
};

export default Index;
