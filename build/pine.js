var PinejsClientCore, Promise, ResinPine, errors, request, utils, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

_ = require('lodash');

Promise = require('bluebird');

PinejsClientCore = require('pinejs-client/core')(_, Promise);

errors = require('resin-errors');

request = require('./request');

utils = require('./utils');

ResinPine = (function(_super) {
  __extends(ResinPine, _super);

  function ResinPine() {
    return ResinPine.__super__.constructor.apply(this, arguments);
  }

  ResinPine.prototype._request = function(params) {
    params.json = true;
    if (params.gzip == null) {
      params.gzip = true;
    }
    return request(params).spread(function(response, body) {
      if (utils.isSuccessfulResponse(response)) {
        return body;
      }
      throw new errors.ResinRequestError(body);
    });
  };

  return ResinPine;

})(PinejsClientCore);

module.exports = new ResinPine({
  apiPrefix: '/ewa/'
});
