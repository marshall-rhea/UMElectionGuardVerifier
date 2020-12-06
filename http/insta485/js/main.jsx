import React from 'react';
import ReactDOM from 'react-dom';
import Index from './index';


// This method is only called once
ReactDOM.render(
  // Insert the likes component into the DOM
  //<Index url="/api/v1/" />,
  <Index url="/api/v1/" />,
  document.getElementById('reactEntry'),
);
