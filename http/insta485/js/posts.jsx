import React from 'react';
import PropTypes from 'prop-types';
import InfiniteScroll from 'react-infinite-scroll-component';
import Post from './post';

class Posts extends React.Component {
  /* Display number of likes a like/unlike button for one post
   * Reference on forms https://facebook.github.io/react/docs/forms.html
   */

  constructor(props) {
    // Initialize mutable state
    super(props);
    this.state = {
      posts: [],
      next: '',
    };
    this.fetch = this.fetch.bind(this);
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
          posts: data.results,
          next: data.next,
        });
      })
      .catch((error) => console.log(error));
  }

  fetch() {
    fetch(this.state.next, { credentials: 'same-origin' })
      .then((response) => {
        if (!response.ok) throw Error(response.statusText);
        return response.json();
      })
      .then((data) => {
        const newArray = this.state.posts.concat(data.results);
        this.setState({
          posts: newArray,
          next: data.next,
        });
      })
      .catch((error) => console.log(error));
  }

  render() {
    let hasMore = false;
    if (this.state.posts.length === 0) {
      return null;
    }
    const posts = this.state.posts.map(
      (post) => <Post url={post.url} key={post.postid} />
      );

    if(this.state.next !== '') {
      hasMore = true;
    }
    // Render number of likes
    return (
        <div className="posts">
        <InfiniteScroll
        dataLength={posts.length}
        next={this.fetch}
        hasMore={hasMore}
        loader={<h4>Loading...</h4>}
        endMessage={
          <p style= {{textAlign: 'center'}} >
            <b>Yay! You have seen it all</b>
          </p>
        }>
        {posts}
      </InfiniteScroll>
      </div>
    );
  }
}

Posts.propTypes = {
  url: PropTypes.string.isRequired,
};

export default Posts;
