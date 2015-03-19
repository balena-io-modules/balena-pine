exports.isSuccessfulResponse = function(response) {
  var _ref;
  return (200 <= (_ref = response.statusCode) && _ref < 300);
};
