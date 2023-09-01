const axios = require('axios');
exports.handler = async function (event, context, callback) {
  // console.log('Running index.handler');
  // console.log('==================================');
  console.log('event', JSON.stringify(event, null, 2));
  // console.log('==================================');
  // console.log('Stopping index.handler');
  var cors_proxy = require('./server');
  // console.log('Testing cors_proxy');

  const headers = Object.entries(event.headers).reduce((acc, [key, value]) => {
    acc[key.toLowerCase()] = value;
    return acc;
  }, {});
  // headers['x-requested-with'] = 'XMLHttpRequest';
  const axiosConfig = {
    method: event.requestContext.http.method,
    // url: event.requestContext.http.path.slice(1) + '?' + event.rawQueryString,
    url: "http://localhost:8080" + event.requestContext.http.path + '?' + event.rawQueryString,
    headers,
    // Optionally, you can pass query parameters in the 'params' property
    // params: requestData.queryStringParameters,
  };
  console.log('axiosConfig:', JSON.stringify(axiosConfig));
  try {
    const response = await axios(axiosConfig);
    console.log('Response:', JSON.stringify(response.data));
    return response.data;
  }
  catch (error) {
    console.log('ErrResponse2:', error.toJSON());
    console.log('ErrResponse22:', error.response);
    // return context.fail(error);
    // return context.fail(error.response);
    // return context.done(error.response);
    return {
      statusCode: error.response.status,
      // body: JSON.stringify(error.response.data),
      body: error.response.data,
    };
    // return error.response;
    // return error.toJSON();
  }

  // callback(null, event);
  // or
  // callback( 'some error type' );
};
